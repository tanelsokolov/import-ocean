import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { MessageSquare, UserRound, Heart, BellDot } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest } from "@/lib/api";
import { Avatar, AvatarImage, AvatarFallback } from "./ui/avatar";

export const Header = () => {
  const navigate = useNavigate();
  const { toast } = useToast();

  const { data: notifications, refetch } = useQuery({
    queryKey: ['notifications'],
    queryFn: () => apiRequest('/api/notifications'),
    refetchInterval: 30000,
  });

  const markNotificationsAsRead = useMutation({
    mutationFn: () => apiRequest('/api/notifications/mark-read', { method: 'POST' }),
    onSuccess: () => {
      refetch();
    },
  });

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

  const handleChatsClick = () => {
    // Mark notifications as read when directly clicking the Chats button
    if (notifications?.unreadMessages > 0) {
      markNotificationsAsRead.mutate();
    }
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
          <Button
            variant="ghost"
            className="flex items-center gap-2"
            onClick={() => navigate("/profile")}
          >
            <UserRound className="w-4 h-4" />
            Profile
          </Button>
          <Button
            variant="ghost"
            className="flex items-center gap-2 relative"
            onClick={() => navigate("/matches")}
          >
            <Heart className="w-4 h-4" />
            Matches
            {notifications?.newMatches > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {notifications.newMatches}
              </span>
            )}
          </Button>
          <Button
            variant="ghost"
            className="flex items-center gap-2 relative"
            onClick={handleChatsClick}
          >
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
          <Button
            onClick={handleLogout}
            variant="outline"
            className="hover:text-match-dark"
          >
            Logout
          </Button>
        </div>
      </div>
    </nav>
  );
};