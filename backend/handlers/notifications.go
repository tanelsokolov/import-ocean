package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type NotificationResponse struct {
	UnreadMessages int `json:"unreadMessages"`
	NewMatches     int `json:"newMatches"`
}

func GetNotificationsHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		userID, err := GetUserIDFromToken(r)
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(map[string]string{"error": "Unauthorized"})
			return
		}

		// Get unread messages count - now includes ALL unread messages
		var unreadMessages int
		err = db.QueryRow(`
			SELECT COUNT(*) FROM chat_messages cm
			JOIN matches m ON cm.match_id = m.id
			WHERE (m.user_id_1 = $1 OR m.user_id_2 = $1)
			AND cm.sender_id != $1
			AND cm.read = false
		`, userID).Scan(&unreadMessages)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
			return
		}

		// Get new matches count (matches that are in 'connected' status)
		var newMatches int
		err = db.QueryRow(`
			SELECT COUNT(*) FROM matches
			WHERE (user_id_1 = $1 OR user_id_2 = $1)
			AND status = 'connected'
			AND updated_at > (
				SELECT COALESCE(last_notification_check, '1970-01-01'::timestamp)
				FROM user_status
				WHERE user_id = $1
			)
		`, userID).Scan(&newMatches)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
			return
		}

		response := NotificationResponse{
			UnreadMessages: unreadMessages,
			NewMatches:     newMatches,
		}

		json.NewEncoder(w).Encode(response)
	}
}

func MarkNotificationsAsReadHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		userID, err := GetUserIDFromToken(r)
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(map[string]string{"error": "Unauthorized"})
			return
		}

		_, err = db.Exec(`
			UPDATE user_status
			SET last_notification_check = CURRENT_TIMESTAMP
			WHERE user_id = $1
		`, userID)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
			return
		}

		json.NewEncoder(w).Encode(map[string]string{"message": "Notifications marked as read"})
	}
}