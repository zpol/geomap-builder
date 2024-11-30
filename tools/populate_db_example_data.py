import random
import argparse
import mysql.connector
from faker import Faker

# Configuración para la conexión a la base de datos
DB_CONFIG = {
    "host": "localhost",         # Cambiar si no es localhost
    "user": "geoip",        # Usuario de la base de datos
    "password": "somestupidvalue678e2gdu3i",  # Contraseña de la base de datos
    "database": "geoip",
    "charset": "utf8mb3"           # Nombre de la base de datos
}

# Coordenadas aproximadas para diferentes continentes
CONTINENTS = {
    "Europe": {"lat_range": (35.0, 70.0), "lon_range": (-10.0, 40.0)},
    "Asia": {"lat_range": (5.0, 60.0), "lon_range": (60.0, 150.0)},
    "North America": {"lat_range": (25.0, 70.0), "lon_range": (-130.0, -60.0)},
    "Africa": {"lat_range": (-35.0, 35.0), "lon_range": (-20.0, 50.0)},
    "Australia": {"lat_range": (-45.0, -10.0), "lon_range": (110.0, 155.0)},
}

# Función para generar una dirección IP aleatoria
def generate_random_ip():
    return Faker().ipv4()

# Función para generar coordenadas aleatorias basadas en un continente
def generate_random_coords(continent):
    lat_range = CONTINENTS[continent]["lat_range"]
    lon_range = CONTINENTS[continent]["lon_range"]
    lat = round(random.uniform(*lat_range), 6)
    lon = round(random.uniform(*lon_range), 6)
    return lat, lon

# Función para insertar registros en la base de datos
def insert_into_db(records):
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # Insertar registros en la tabla
        insert_query = """
        INSERT INTO geoip_data (public_ip_addr, lat, lon, metadata)
        VALUES (%s, %s, %s, %s)
        """
        cursor.executemany(insert_query, records)
        conn.commit()
        print(f"{cursor.rowcount} registros insertados exitosamente.")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

# Generar registros
def generate_records(num_ips):
    records = []
    continents = list(CONTINENTS.keys())
    for _ in range(num_ips):
        ip = generate_random_ip()
        continent = random.choice(continents)
        lat, lon = generate_random_coords(continent)
        metadata = {"continent": continent}
        records.append((ip, lat, lon, str(metadata)))
    return records

# Configurar argumentos de línea de comandos
def main():
    parser = argparse.ArgumentParser(description="Populate geoip database with random IPs and coordinates.")
    parser.add_argument("num_ips", type=int, help="Number of random IPs to generate and insert.")
    args = parser.parse_args()

    print(f"Generando {args.num_ips} registros aleatorios...")
    records = generate_records(args.num_ips)

    print("Insertando registros en la base de datos...")
    insert_into_db(records)

if __name__ == "__main__":
    main()
