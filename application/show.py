from tabulate import tabulate
import os

def show_results(cursor):
    os.system('cls' if os.name == 'nt' else 'clear')
    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    if rows:
        print(tabulate(rows, headers=columns, tablefmt="grid"))
    else:
        print("⚠️ No results found.")