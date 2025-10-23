import random

def generate_mac():
    # Генерируем случайные байты (5 байт = 40 бит)
    random_bytes = [random.randint(0x00, 0xff) for _ in range(5)]
    
    # Первый байт: устанавливаем биты для локального управления (0x02)
    # Бит 0 (младший): 0 = универсальный, 1 = локальный
    # Бит 1: 0 = индивидуальный, 1 = групповой
    first_byte = 0x02 | (random.randint(0, 0x3f) << 2)  # Добавляем случайность в старшие 6 бит
    
    return ':'.join(f'{b:02x}' for b in [first_byte] + random_bytes)

# Пример использования
if __name__ == "__main__":
    print(generate_mac())