package handlers

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

type NotificationResponse struct {
	UnreadMessages int `json:"unreadMessages"`
	NewMatches     int `json:"newMatches"`
}

var notificationConnections = make(map[int]*websocket.Conn)
var notifLock sync.Mutex

func GetNotificationsHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		userID, err := GetUserIDFromToken(r)
		if err != nil {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(map[string]string{"error": "Unauthorized"})
			return
		}

		// Get the last notification check time
		var lastCheck sql.NullTime
		err = db.QueryRow(`
			SELECT last_notification_check FROM user_status WHERE user_id = $1
		`, userID).Scan(&lastCheck)
		if err != nil && err != sql.ErrNoRows {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
			return
		}

		// Get unread messages count
		var unreadMessages int
		err = db.QueryRow(`
			SELECT COUNT(*) FROM chat_messages cm
			JOIN matches m ON cm.match_id = m.id
			WHERE (m.user_id_1 = $1 OR m.user_id_2 = $1)
			AND cm.sender_id != $1
			AND cm.read = false
			AND ($2::timestamp IS NULL OR cm.timestamp > $2)
		`, userID, lastCheck).Scan(&unreadMessages)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(map[string]string{"error": "Database error"})
			return
		}

		// Get new matches count
		var newMatches int
		err = db.QueryRow(`
			SELECT COUNT(*) FROM matches
			WHERE (user_id_1 = $1 OR user_id_2 = $1)
			AND status = 'connected'
			AND ($2::timestamp IS NULL OR created_at > $2)
		`, userID, lastCheck).Scan(&newMatches)
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

func HandleNotificationWebSocket() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, err := GetUserIDFromToken(r)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		upgrader := websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool { return true },
		}
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.Println("WebSocket upgrade error:", err)
			return
		}
		defer conn.Close()

		notifLock.Lock()
		notificationConnections[userID] = conn
		notifLock.Unlock()

		for {
			_, _, err := conn.ReadMessage()
			if err != nil {
				notifLock.Lock()
				delete(notificationConnections, userID)
				notifLock.Unlock()
				break
			}
		}
	}
}

// Broadcast notification to a user
func SendNotification(userID int, messageType string) {
	notifLock.Lock()
	conn, exists := notificationConnections[userID]
	notifLock.Unlock()

	if exists {
		data, _ := json.Marshal(map[string]string{
			"type": messageType,
		})
		conn.WriteMessage(websocket.TextMessage, data)
	}
}
