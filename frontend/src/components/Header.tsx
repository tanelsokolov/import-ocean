import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { MessageSquare, UserRound, Heart, BellDot } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/api";

export const Header = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [unreadMessages, setUnreadMessages] = useState(0);
  const [newMatches, setNewMatches] = useState(0);

  // Fetch initial notifications **(Runs only once)** 
  useQuery({
    queryKey: ["notifications"],
    queryFn: async () => {
      const res = await apiRequest("/api/notifications");
      setUnreadMessages(res.unreadMessages);
      setNewMatches(res.newMatches);
      return res;
    },
  });

  // Mark notifications as read
  const markNotificationsAsRead = useMutation({
    mutationFn: () => apiRequest("/api/notifications/mark-read", { method: "POST" }),
    onSuccess: () => {
      setUnreadMessages(0);
    },
  });

  // Establish WebSocket connection
  useEffect(() => {
    const connectWebSocket = () => {
      const token = localStorage.getItem("token");
      if (!token) {
        console.error("No token available");
        return;
      }

      const websocket = new WebSocket(`ws://localhost:3000/ws/notifications?token=${token}`);

      websocket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);

          if (data.type === "notification" || data.type === "message") {
            // **Update state directly (No polling or refetch)**
            if (data.unreadMessages !== undefined) {
              setUnreadMessages(data.unreadMessages);
            }
            if (data.newMatches !== undefined) {
              setNewMatches(data.newMatches);
            }
          }
        } catch (err) {
          console.error("Error parsing WebSocket message:", err);
        }
      };

      websocket.onclose = () => {
        setTimeout(connectWebSocket, 5000); // Reconnect after 5 seconds if closed
      };

      setWs(websocket);
    };

    connectWebSocket();

    return () => {
      ws?.close();
    };
  }, []);

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    toast({ title: "Logged out successfully", description: "See you next time!" });
    navigate("/");
  };

  return (
    <nav className="bg-white shadow-md p-4">
      <div className="max-w-4xl mx-auto flex justify-between items-center">
        <h1 
          onClick={() => navigate("/dashboard")}
          className="text-2xl font-bold bg-gradient-to-r from-match-light to-match-dark text-transparent bg-clip-text cursor-pointer"
        >
          Match Me
        </h1>
        <div className="flex gap-4">
          <Button variant="ghost" className="flex items-center gap-2" onClick={() => navigate("/profile")}>
            <UserRound className="w-4 h-4" />
            Profile
          </Button>
          <Button variant="ghost" className="flex items-center gap-2 relative" onClick={() => navigate("/matches")}>
            <Heart className="w-4 h-4" />
            Matches
            {newMatches > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {newMatches}
              </span>
            )}
          </Button>
          <Button
            variant="ghost"
            className="flex items-center gap-2 relative"
            onClick={async () => {
              navigate("/chats");
            //setUnreadMessages(0); // Reset unread messages when clicking on chats
              await markNotificationsAsRead.mutateAsync();
            }}
          >
            {unreadMessages > 0 ? (
              <BellDot className="w-4 h-4 text-red-500" />
            ) : (
              <MessageSquare className="w-4 h-4" />
            )}
            Chats
            {unreadMessages > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {unreadMessages}
              </span>
            )}
          </Button>

          <Button onClick={handleLogout} variant="outline" className="hover:text-match-dark">
            Logout
          </Button>
        </div>
      </div>
    </nav>
  );
};
