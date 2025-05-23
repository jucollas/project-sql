from show import show_results

def exchange_history(conn, user_id):
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM TABLE(historial_intercambios(:user_id))", {'user_id': user_id})
        print(f"\n📚 Exchange history for user {user_id}:")
        show_results(cursor)
    except Exception as e:
        print("❌ Error in exchange_history:", e)
    finally:
        cursor.close()

def consecutive_donations(conn):
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM TABLE(donaciones_consecutivas)")
        print("\n🎁 Consecutive donations:")
        show_results(cursor)
    except Exception as e:
        print("❌ Error in consecutive_donations:", e)
    finally:
        cursor.close()

def most_active_users(conn, limit, year):
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM TABLE(usuarios_mas_activos(:limit, :year))",
                       {'limit': limit, 'year': year})
        print(f"\n🔥 Top {limit} most active users in {year}:")
        show_results(cursor)
    except Exception as e:
        print("❌ Error in most_active_users:", e)
    finally:
        cursor.close()

def suggest_exchange(conn, user_id, genre_filter=None):
    cursor = conn.cursor()
    try:
        if genre_filter:
            cursor.execute("""
                SELECT * FROM TABLE(sugerir_intercambio(:user_id, :genre_filter))
                """, {'user_id': user_id, 'genre_filter': genre_filter})
        else:
            cursor.execute("""
                SELECT * FROM TABLE(sugerir_intercambio(:user_id))
                """, {'user_id': user_id})
        
        print(f"\n📚 Exchange suggestions for user {user_id}" +
              (f" with filter '{genre_filter}'" if genre_filter else "") + ":")
        show_results(cursor)
    except Exception as e:
        print("❌ Error in suggest_exchange:", e)
    finally:
        cursor.close()