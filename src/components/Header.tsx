import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { MessageSquare, UserRound, Heart, BellDot } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/api";
import { Avatar, AvatarImage, AvatarFallback } from "./ui/avatar";

export const Header = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const [ws, setWs] = useState<WebSocket | null>(null);
  const [unreadMessages, setUnreadMessages] = useState(0);
  const [newMatches, setNewMatches] = useState(0);

  // Fetch initial notifications
  const { data, refetch } = useQuery({
    queryKey: ["notifications"],
    queryFn: async () => {
      const res = await apiRequest("/api/notifications");
      setUnreadMessages(res.unreadMessages);
      setNewMatches(res.newMatches);
      return res;
    },
    refetchInterval: 100, // Refetch every 30 seconds
  });

  // Mark notifications as read
  const markNotificationsAsRead = useMutation({
    mutationFn: () => apiRequest("/api/notifications/mark-read", { method: "POST" }),
    onSuccess: () => {
      setUnreadMessages(0);
      refetch();
    },
  });

  // Establish WebSocket connection
  useEffect(() => {
    const connectWebSocket = () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          console.error("No token available");
          return;
        }
  
        const websocket = new WebSocket(`ws://localhost:3000/ws/notifications?token=${token}`);
  
        websocket.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data);
            console.log("Received WebSocket message:", data);
        
            // Handle both connection and notification messages
            if (data.type === "notification" || data.type === "message") {
              queryClient.invalidateQueries({ queryKey: ["notifications"] });
              
              // Update local state if the data contains these values
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
  
        websocket.onclose = (event) => {
          console.log("WebSocket closed with code:", event.code);
          setTimeout(connectWebSocket, 5000);
        };
  
        setWs(websocket);
      } catch (error) {
        console.error("WebSocket connection error:", error);
      }
    };
  
    connectWebSocket();
  
    return () => {
      ws?.close();
    };
  }, [queryClient]);
  

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
          <Button variant="ghost" className="flex items-center gap-2 relative" onClick={() => {
            markNotificationsAsRead.mutate();
            navigate("/chats");
          }}>
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
