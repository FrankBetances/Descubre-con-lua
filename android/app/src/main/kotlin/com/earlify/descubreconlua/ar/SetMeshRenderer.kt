package com.earlify.descubreconlua.ar

import android.content.res.AssetManager
import android.opengl.EGL14
import android.opengl.EGLContext
import android.opengl.GLES20
import android.opengl.Matrix
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Dibuja las piezas 3D (.vmesh) sobre la mesa a escala 1:1 en hilo GL.
 * Portado de Valeria (P10.4).
 */
class SetMeshRenderer(private val assets: AssetManager) {

    private class Mesh(val vbo: Int, val count: Int)

    private val meshes = HashMap<String, Mesh?>()
    private var program = 0
    private var aPos = 0
    private var aNormal = 0
    private var uMvp = 0
    private var uModel = 0
    private var uColor = 0
    private val mvp = FloatArray(16)
    private var context: EGLContext? = null

    private fun ensureProgram(): Boolean {
        val current = EGL14.eglGetCurrentContext()
        if (current != context) {
            context = current
            meshes.clear()
            program = 0
        }
        if (program != 0) return true
        val vs = compile(GLES20.GL_VERTEX_SHADER, VERTEX_SRC)
        val fs = compile(GLES20.GL_FRAGMENT_SHADER, FRAGMENT_SRC)
        if (vs == 0 || fs == 0) return false
        val p = GLES20.glCreateProgram()
        GLES20.glAttachShader(p, vs)
        GLES20.glAttachShader(p, fs)
        GLES20.glLinkProgram(p)
        val status = IntArray(1)
        GLES20.glGetProgramiv(p, GLES20.GL_LINK_STATUS, status, 0)
        if (status[0] == 0) {
            Log.e(TAG, "Shader link error: ${GLES20.glGetProgramInfoLog(p)}")
            GLES20.glDeleteProgram(p)
            return false
        }
        program = p
        aPos = GLES20.glGetAttribLocation(p, "a_Pos")
        aNormal = GLES20.glGetAttribLocation(p, "a_Normal")
        uMvp = GLES20.glGetUniformLocation(p, "u_Mvp")
        uModel = GLES20.glGetUniformLocation(p, "u_Model")
        uColor = GLES20.glGetUniformLocation(p, "u_Color")
        return true
    }

    private fun compile(type: Int, src: String): Int {
        val s = GLES20.glCreateShader(type)
        GLES20.glShaderSource(s, src)
        GLES20.glCompileShader(s)
        val status = IntArray(1)
        GLES20.glGetShaderiv(s, GLES20.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) {
            GLES20.glDeleteShader(s)
            return 0
        }
        return s
    }

    private fun mesh(name: String): Mesh? {
        if (meshes.containsKey(name)) return meshes[name]
        val loaded = try {
            val bytes = assets.open("sets/$name.vmesh").use { it.readBytes() }
            val buf = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN)
            val magic = ByteArray(4).also { buf.get(it) }
            require(String(magic, Charsets.US_ASCII) == "VM01") { "magic" }
            val count = buf.int
            require(count > 0 && bytes.size == 8 + count * 24) { "size" }
            val direct = ByteBuffer.allocateDirect(count * 24).order(ByteOrder.nativeOrder())
            direct.asFloatBuffer().put(buf.asFloatBuffer())
            val ids = IntArray(1)
            GLES20.glGenBuffers(1, ids, 0)
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, ids[0])
            GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, count * 24, direct, GLES20.GL_STATIC_DRAW)
            GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
            Mesh(ids[0], count)
        } catch (t: Throwable) {
            Log.w(TAG, "No vmesh for $name", t)
            null
        }
        meshes[name] = loaded
        return loaded
    }

    fun begin(): Boolean {
        if (!ensureProgram()) return false
        GLES20.glUseProgram(program)
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(true)
        return true
    }

    fun draw(name: String, viewProj: FloatArray, model: FloatArray, r: Float, g: Float, b: Float, alpha: Float) {
        val m = mesh(name) ?: return
        Matrix.multiplyMM(mvp, 0, viewProj, 0, model, 0)
        GLES20.glUniformMatrix4fv(uMvp, 1, false, mvp, 0)
        GLES20.glUniformMatrix4fv(uModel, 1, false, model, 0)
        GLES20.glUniform4f(uColor, r, g, b, alpha)
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, m.vbo)
        GLES20.glEnableVertexAttribArray(aPos)
        GLES20.glEnableVertexAttribArray(aNormal)
        GLES20.glVertexAttribPointer(aPos, 3, GLES20.GL_FLOAT, false, 24, 0)
        GLES20.glVertexAttribPointer(aNormal, 3, GLES20.GL_FLOAT, false, 24, 12)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, m.count)
    }

    fun end() {
        GLES20.glDisableVertexAttribArray(aPos)
        GLES20.glDisableVertexAttribArray(aNormal)
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
        GLES20.glDisable(GLES20.GL_BLEND)
    }

    companion object {
        private const val TAG = "LuaSetMeshRenderer"
        private const val VERTEX_SRC = """
            uniform mat4 u_Mvp;
            uniform mat4 u_Model;
            attribute vec3 a_Pos;
            attribute vec3 a_Normal;
            varying vec3 v_Normal;
            void main() {
                gl_Position = u_Mvp * vec4(a_Pos, 1.0);
                v_Normal = normalize(mat3(u_Model) * a_Normal);
            }
        """
        private const val FRAGMENT_SRC = """
            precision mediump float;
            varying vec3 v_Normal;
            uniform vec4 u_Color;
            void main() {
                vec3 l = normalize(vec3(0.35, 0.9, 0.45));
                float k = 0.48 + 0.52 * max(dot(normalize(v_Normal), l), 0.0);
                gl_FragColor = vec4(u_Color.rgb * k, u_Color.a);
            }
        """
    }
}
