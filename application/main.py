from functions import exchange_history, consecutive_donations, most_active_users, suggest_exchange
from connect import connect

def menu():
    conn = connect()
    if not conn:
        return

    while True:
        print("\n🧭 Menu:")
        print("1. Exchange history (requires user_id)")
        print("2. Consecutive donations")
        print("3. Most active users (requires limit and year)")
        print("4. Suggest exchange (requires user_id, optional genre)")
        print("5. Exit")
        option = input("Select an option: ")

        if option == '1':
            try:
                uid = int(input("🔹 Enter user_id: "))
                exchange_history(conn, uid)
            except ValueError:
                print("⚠️ user_id must be a number.")
        elif option == '2':
            consecutive_donations(conn)
        elif option == '3':
            try:
                limit = int(input("🔹 Enter number of users to show: "))
                year = int(input("🔹 Enter year: "))
                most_active_users(conn, limit, year)
            except ValueError:
                print("⚠️ Limit and year must be numbers.")
        elif option == '4':
            try:
                uid = int(input("🔹 Enter user_id: "))
                genre = input("🔹 Enter genre (optional, press ENTER to skip): ").strip()
                genre = genre if genre else None
                suggest_exchange(conn, uid, genre)
            except ValueError:
                print("⚠️ user_id must be a number.")
        elif option == '5':
            print("👋 Exiting...")
            break
        else:
            print("❌ Invalid option. Please try again.")

    conn.close()

if __name__ == '__main__':
    menu()
