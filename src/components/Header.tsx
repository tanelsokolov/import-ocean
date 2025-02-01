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
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [ws, setWs] = useState<WebSocket | null>(null);

  const { data: notifications, refetch } = useQuery({
    queryKey: ["notifications"],
    queryFn: () => apiRequest("/api/notifications"),
    refetchInterval: 30000, // Refetch every 30 seconds
  });

  const markNotificationsAsRead = useMutation({
    mutationFn: () => apiRequest("/api/notifications/mark-read", { method: "POST" }),
    onSuccess: () => {
      refetch();
    },
  });

  useEffect(() => {
    const connectWebSocket = () => {
      const token = localStorage.getItem("token");
      if (!token) return;

      const websocket = new WebSocket(`ws://localhost:3000/ws/notifications?token=${token}`);

      websocket.onopen = () => {
        console.log("Notification WebSocket connected");
      };

      websocket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        
        if (data.type === "new_message" || data.type === "new_match") {
          queryClient.invalidateQueries({ queryKey: ["notifications"] });
        }
      };

      websocket.onclose = () => {
        console.log("Notification WebSocket disconnected, reconnecting...");
        setTimeout(connectWebSocket, 5000); // Reconnect after 5s
      };

      setWs(websocket);
    };

    connectWebSocket();

    return () => {
      ws?.close();
    };
  }, [queryClient]);

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    toast({
      title: "Logged out successfully",
      description: "See you next time!",
    });
    navigate("/");
  };

  const handleNotificationsClick = () => {
    markNotificationsAsRead.mutate();
    navigate("/chats");
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
            {notifications?.newMatches > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {notifications.newMatches}
              </span>
            )}
          </Button>
          <Button variant="ghost" className="flex items-center gap-2 relative" onClick={handleNotificationsClick}>
            {notifications?.unreadMessages > 0 ? (
              <BellDot className="w-4 h-4 text-red-500" />
            ) : (
              <MessageSquare className="w-4 h-4" />
            )}
            Chats
            {notifications?.unreadMessages > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {notifications.unreadMessages}
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
