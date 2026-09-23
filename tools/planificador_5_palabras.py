#!/usr/bin/env python3
"""
Planificador y Generador de Currículo Léxico TPR: Ritmo de 5 Palabras Diarias
Proyecto: Descubre con Lúa (Metodología Cero Pantallas para la Criatura)
"""
import json
import sys


class PlanificadorTPR:
    def __init__(self):
        self.dias_semana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]

    def generar_semana(self, num_semana: int, banco_20_palabras: list) -> dict:
        if len(banco_20_palabras) < 20:
            raise ValueError("Se requieren al menos 20 palabras por semana.")

        b_a = banco_20_palabras[0:5]   # Lunes
        b_b = banco_20_palabras[5:10]  # Martes
        b_c = banco_20_palabras[10:15] # Miércoles
        b_d = banco_20_palabras[15:20] # Jueves

        return {
            "semana": num_semana,
            "dias": {
                "Lunes": {"nuevas": b_a, "refuerzo": [], "carga": 5, "dinamica": "Modelado motriz directo."},
                "Martes": {"nuevas": b_b, "refuerzo": b_a, "carga": 10, "dinamica": "Juego rápido de velocidad con Bloque A."},
                "Miércoles": {"nuevas": b_c, "refuerzo": b_a + b_b, "carga": 15, "dinamica": "Circuito TPR combinando A, B y C."},
                "Jueves": {"nuevas": b_d, "refuerzo": b_a + b_b + b_c, "carga": 20, "dinamica": "Cuento motor con las 20 palabras."},
                "Viernes": {"nuevas": [], "refuerzo": banco_20_palabras[0:20], "carga": 20, "dinamica": "¡Gran Reto TPR Acumulativo!"}
            }
        }

    def calcular_rendimiento_anual(self) -> dict:
        palabras_curso = 5 * 4 * 4 * 10  # 800 palabras
        return {
            "total_anual": palabras_curso,
            "desglose": {
                "Sustantivos (Nouns) ~35%": int(palabras_curso * 0.35),
                "Verbos de Acción (Verbs) ~25%": int(palabras_curso * 0.25),
                "Adjetivos/Sensorial ~20%": int(palabras_curso * 0.20),
                "Oraciones/Preguntas ~12%": int(palabras_curso * 0.12),
                "Complejas/Conectores ~8%": int(palabras_curso * 0.08)
            }
        }


def main():
    planificador = PlanificadorTPR()
    rendimiento = planificador.calcular_rendimiento_anual()
    print("=== Rendimiento Anual del Modelo TPR 800 Palabras ===")
    print(f"Total Palabras Anual: {rendimiento['total_anual']}")
    for cat, total in rendimiento["desglose"].items():
        print(f"  - {cat}: {total} palabras")

    # Muestra de prueba de semana 1
    palabras_demo = [
        "Head", "Shoulders", "Knees", "Toes", "Freeze",
        "Eyes", "Ears", "Mouth", "Nose", "Jump",
        "Hands", "Feet", "Walk", "Stop", "Turn",
        "Big", "Small", "Up", "Down", "Clap"
    ]
    semana1 = planificador.generar_semana(1, palabras_demo)
    print("\n=== Plan Semanal Generado (Semana 1) ===")
    print(json.dumps(semana1, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
