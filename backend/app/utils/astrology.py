from datetime import datetime
from typing import Optional
import math


class NumerologyUtils:
    """Numerology calculation utilities"""

    @staticmethod
    def reduce_to_single_digit(number: int) -> int:
        """Reduce number to single digit (1-9)"""
        if number <= 0:
            return 1
        while number > 9:
            number = sum(int(digit) for digit in str(number))
        return number

    @staticmethod
    def calculate_life_path_number(birth_date: datetime) -> int:
        """
        Calculate life path number from birth date.
        Sum all digits of DOB, reduce to single digit (1-9)
        """
        day = birth_date.day
        month = birth_date.month
        year = birth_date.year

        # Sum all digits
        total = day + month + year
        return NumerologyUtils.reduce_to_single_digit(total)

    @staticmethod
    def calculate_daily_lucky_number(
        life_path: int, current_date: datetime
    ) -> int:
        """
        Calculate daily lucky number.
        Formula: (Life Path + Day + Month + Year) % 9
        If result is 0, return 9
        """
        day = current_date.day
        month = current_date.month
        year = current_date.year

        total = (life_path + day + month + year) % 9
        return total if total != 0 else 9

    @staticmethod
    def calculate_destiny_number(full_name: str) -> int:
        """
        Calculate destiny number from full name.
        Maps each letter to number (A=1, B=2, ..., Z=26)
        """
        if not full_name:
            return 1

        # Letter to number mapping
        name_sum = 0
        for char in full_name.upper():
            if char.isalpha():
                name_sum += ord(char) - ord("A") + 1

        return NumerologyUtils.reduce_to_single_digit(name_sum)

    @staticmethod
    def get_lucky_color(lucky_number: int) -> str:
        """Map lucky number (1-9) to color"""
        colors = {
            1: "#FFD700",  # Gold
            2: "#FFC0CB",  # Pink
            3: "#FF6347",  # Red
            4: "#4169E1",  # Blue
            5: "#32CD32",  # Green
            6: "#9370DB",  # Purple
            7: "#FF8C00",  # Orange
            8: "#DC143C",  # Crimson
            9: "#00CED1",  # Dark Turquoise
        }
        return colors.get(lucky_number, "#FFD700")

    @staticmethod
    def calculate_lucky_time(
        life_path: int, current_hour: int = None
    ) -> str:
        """
        Calculate lucky time (hour).
        Formula: (Life Path + Current Hour) % 24
        Avoid night hours (0-5), default to current hour if not provided
        """
        if current_hour is None:
            current_hour = datetime.now().hour

        lucky_hour = (life_path + current_hour) % 24

        # Avoid night hours
        if lucky_hour < 6:
            lucky_hour = (lucky_hour + 6) % 24

        return f"{lucky_hour:02d}:00"

    @staticmethod
    def calculate_energy_level(
        daily_lucky_number: int, life_path: int, moon_phase: int = None
    ) -> tuple:
        """
        Calculate energy level (High, Medium, Low).
        Returns (level_name, value_0_to_100)
        """
        if moon_phase is None:
            moon_phase = 50  # Default to half moon

        # Calculate base energy
        base = (daily_lucky_number * 10 + life_path * 5) % 100

        # Add moon phase influence
        energy = (base + moon_phase) // 2

        # Determine level
        if energy >= 70:
            level = "High"
        elif energy >= 40:
            level = "Medium"
        else:
            level = "Low"

        return level, energy


class LotteryUtils:
    """Lottery number generation utilities"""

    LOTTERY_TYPES = {
        "6/49": {"count": 6, "min": 1, "max": 49},
        "Powerball": {"count": 5, "min": 1, "max": 69, "bonus": (1, 26)},
        "Megamillions": {"count": 5, "min": 1, "max": 70, "bonus": (1, 25)},
        "4-Digit": {"count": 4, "min": 0, "max": 9, "repeat": True},
        "3-Digit": {"count": 3, "min": 0, "max": 9, "repeat": True},
        "Euromillions": {"count": 5, "min": 1, "max": 50, "stars": (1, 12)},
    }

    MULTIPLIERS = [3, 5, 7, 9, 11]

    @staticmethod
    def generate_lottery_numbers(
        lucky_number: int, lottery_type: str, seed: int = None
    ) -> list:
        """
        Generate lottery numbers based on astrology values.
        Formula: (Lucky Number × Multiplier) % MaxRange
        """
        if lottery_type not in LotteryUtils.LOTTERY_TYPES:
            lottery_type = "6/49"

        config = LotteryUtils.LOTTERY_TYPES[lottery_type]
        count = config["count"]
        min_val = config["min"]
        max_val = config["max"]
        allow_repeat = config.get("repeat", False)

        numbers = set()
        multiplier_idx = (seed or luck_number) % len(LotteryUtils.MULTIPLIERS)

        for i in range(count):
            multiplier = LotteryUtils.MULTIPLIERS[
                (multiplier_idx + i) % len(LotteryUtils.MULTIPLIERS)
            ]
            num = (lucky_number * multiplier) % (max_val - min_val + 1) + min_val

            if not allow_repeat:
                # Ensure uniqueness
                attempts = 0
                while num in numbers and attempts < 100:
                    multiplier = (multiplier + 1) % 12
                    num = (lucky_number * multiplier) % (
                        max_val - min_val + 1
                    ) + min_val
                    attempts += 1

            numbers.add(num)

        numbers_list = sorted(list(numbers))[:count]

        # Add bonus numbers if needed
        if "bonus" in config:
            bonus_min, bonus_max = config["bonus"]
            bonus = (lucky_number * 13) % (bonus_max - bonus_min + 1) + bonus_min
            numbers_list.append(bonus)

        if "stars" in config:
            stars_min, stars_max = config["stars"]
            stars = (lucky_number * 17) % (stars_max - stars_min + 1) + stars_min
            numbers_list.append(stars)

        return numbers_list

    @staticmethod
    def format_numbers_for_lottery(numbers: list, lottery_type: str) -> str:
        """Format generated numbers as string for specific lottery"""
        if lottery_type == "Powerball":
            return f"{','.join(map(str, numbers[:5]))} PB:{numbers[5]}"
        elif lottery_type == "Megamillions":
            return f"{','.join(map(str, numbers[:5]))} MM:{numbers[5]}"
        elif lottery_type == "Euromillions":
            return f"{','.join(map(str, numbers[:5]))} *{','.join(map(str, numbers[5:]))}"
        else:
            return ",".join(map(str, numbers))

    @staticmethod
    def get_lottery_info(lottery_type: str) -> dict:
        """Get information about a specific lottery"""
        if lottery_type not in LotteryUtils.LOTTERY_TYPES:
            return {}
        return {
            "type": lottery_type,
            **LotteryUtils.LOTTERY_TYPES[lottery_type],
        }


class DateUtils:
    """Date and time utilities"""

    @staticmethod
    def get_moon_phase(date: datetime) -> int:
        """
        Approximate moon phase (0-100).
        This is a simplified calculation.
        0 = New Moon, 50 = Full Moon, 100 = New Moon again
        """
        # Known new moon date
        known_new_moon = datetime(2000, 1, 6)
        days_since = (date - known_new_moon).days

        # Moon cycle is approximately 29.53 days
        phase = (days_since % 29.53) / 29.53 * 100
        return int(phase)

    @staticmethod
    def get_zodiac_sign(month: int, day: int) -> str:
        """Get zodiac sign from birth month and day"""
        zodiac_signs = [
            ("Capricorn", (12, 22), (1, 19)),
            ("Aquarius", (1, 20), (2, 18)),
            ("Pisces", (2, 19), (3, 20)),
            ("Aries", (3, 21), (4, 19)),
            ("Taurus", (4, 20), (5, 20)),
            ("Gemini", (5, 21), (6, 20)),
            ("Cancer", (6, 21), (7, 22)),
            ("Leo", (7, 23), (8, 22)),
            ("Virgo", (8, 23), (9, 22)),
            ("Libra", (9, 23), (10, 22)),
            ("Scorpio", (10, 23), (11, 21)),
            ("Sagittarius", (11, 22), (12, 21)),
        ]

        for sign, start, end in zodiac_signs:
            if (month == start[0] and day >= start[1]) or (
                month == end[0] and day <= end[1]
            ):
                return sign

        return "Capricorn"


__all__ = ["NumerologyUtils", "LotteryUtils", "DateUtils"]
