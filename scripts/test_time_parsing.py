#!/usr/bin/env python3
"""
Test script to verify the time parsing logic works correctly
This tests the fix for CSV upload start_time constraint violation
"""

def normalize_time(start_time):
    """
    Normalize time format - ensure it's in HH:MM format
    This is the same logic used in backend/main.py
    """
    if start_time:
        try:
            # Remove AM/PM suffix and handle 12-hour format
            time_str = start_time.upper().strip()
            is_pm = 'PM' in time_str
            is_am = 'AM' in time_str
            time_str = time_str.replace('AM', '').replace('PM', '').strip()

            # Try to parse various time formats
            if ":" in time_str:
                time_parts = time_str.split(":")
                if len(time_parts) >= 2:
                    hour = int(time_parts[0])
                    minute = int(time_parts[1].split()[0])  # Handle any trailing text

                    # Convert 12-hour to 24-hour if AM/PM was present
                    if is_pm and hour != 12:
                        hour += 12
                    elif is_am and hour == 12:
                        hour = 0

                    start_time = f"{hour:02d}:{minute:02d}"
            else:
                # If no colon, assume it's just hours
                hour = int(time_str)
                if is_pm and hour != 12:
                    hour += 12
                elif is_am and hour == 12:
                    hour = 0
                start_time = f"{hour:02d}:00"
        except (ValueError, IndexError):
            # If parsing fails, use default
            start_time = "09:00"
    else:
        # CRITICAL FIX: If no start_time provided, use default
        # This prevents empty string from violating NOT NULL constraint
        start_time = "09:00"

    return start_time


def run_tests():
    """Run test cases for time normalization"""
    test_cases = [
        # Format: (input, expected_output, description)
        ("09:00 AM", "09:00", "Morning time with AM"),
        ("10:00 AM", "10:00", "10 AM"),
        ("12:00 PM", "12:00", "Noon (12 PM)"),
        ("12:00 AM", "00:00", "Midnight (12 AM)"),
        ("01:00 PM", "13:00", "Afternoon time with PM"),
        ("02:00 PM", "14:00", "2 PM"),
        ("11:00 PM", "23:00", "11 PM"),
        ("12:00", "12:00", "24-hour format - noon"),
        ("13:00", "13:00", "24-hour format - 1 PM"),
        ("16:30", "16:30", "24-hour format with minutes"),
        ("9:30", "09:30", "Single digit hour"),
        ("", "09:00", "Empty string - should use default"),
        (None, "09:00", "None value - should use default"),
        ("   ", "09:00", "Whitespace only - should use default"),
    ]

    print("=" * 70)
    print("CSV Upload Time Parsing Tests")
    print("=" * 70)
    print()

    passed = 0
    failed = 0

    for input_time, expected, description in test_cases:
        result = normalize_time(input_time)
        status = "✅ PASS" if result == expected else "❌ FAIL"

        if result == expected:
            passed += 1
        else:
            failed += 1

        print(f"{status} | Input: {repr(input_time):20} | Expected: {expected:8} | Got: {result:8} | {description}")

    print()
    print("=" * 70)
    print(f"Results: {passed} passed, {failed} failed out of {len(test_cases)} tests")
    print("=" * 70)

    return failed == 0


if __name__ == "__main__":
    success = run_tests()
    exit(0 if success else 1)
