import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Button } from "./ui/button";
import { ScrollArea } from "./ui/scroll-area";
import { Card } from "./ui/card";
import { Textarea } from "./ui/textarea";
import { useState, useEffect, useRef } from "react";
import { useToast } from "./ui/use-toast";
import { Avatar, AvatarImage, AvatarFallback } from "./ui/avatar";
import { useWebSocket } from "@/contexts/WebSocketContext";

interface Message {
  id: string;
  sender_id: number;
  content: string;
  timestamp: string;
  read: boolean;
}

interface ChatProps {
  matchId?: number;
  currentUserId?: number;
  otherUserName?: string;
  otherUserPicture?: string;
}

export const Chat = ({ matchId, currentUserId, otherUserName, otherUserPicture }: ChatProps) => {
  const queryClient = useQueryClient();
  const [message, setMessage] = useState("");
  const { toast } = useToast();
  const [localMessages, setLocalMessages] = useState<Message[]>([]);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const { connectWebSocket, sendMessage, isConnected } = useWebSocket();

  const { data: initialMessages, refetch } = useQuery({
    queryKey: ['messages', matchId],
    queryFn: async () => {
      if (!matchId) return { messages: [] };
      const token = localStorage.getItem('token');
      const response = await fetch(`http://localhost:3000/api/matches/${matchId}/messages`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (!response.ok) {
        throw new Error('Failed to fetch messages');
      }
      const data = await response.json();
      return data;
    },
    enabled: !!matchId,
  });

  useEffect(() => {
    if (initialMessages?.messages) {
      setLocalMessages(initialMessages.messages);
    }
  }, [initialMessages]);

  useEffect(() => {
    if (matchId && currentUserId) {
      connectWebSocket(matchId);
    }
  }, [matchId, currentUserId]);

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [localMessages]);

  useEffect(() => {
    if (matchId && currentUserId) {
      const token = localStorage.getItem('token');
      fetch(`http://localhost:3000/api/matches/${matchId}/messages/read`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }).then(() => {
        refetch();
        // Also invalidate notifications when marking messages as read
        queryClient.invalidateQueries({ queryKey: ['notifications'] });
      });
    }
  }, [matchId, currentUserId, refetch, queryClient]);

  const handleSendMessage = async () => {
    if (!message.trim() || !matchId || !currentUserId) {
      if (!matchId || !currentUserId) {
        toast({
          title: "Error",
          description: "Cannot send message - chat not properly initialized",
          variant: "destructive",
        });
      }
      return;
    }

    try {
      const messageData = {
        id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        content: message,
        sender_id: currentUserId,
        timestamp: new Date().toISOString(),
        read: false
      };
      
      sendMessage(matchId, messageData);
      setLocalMessages(prev => [...(Array.isArray(prev) ? prev : []), messageData]);
      setMessage("");
      
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
      setTimeout(() => refetch(), 500);
    } catch (error) {
      console.error('Error sending message:', error);
      toast({
        title: "Error",
        description: "Failed to send message",
        variant: "destructive",
      });
    }
  };

  if (!matchId || !currentUserId) {
    return (
      <div className="flex-1 flex items-center justify-center text-gray-500">
        Select a chat to start messaging
      </div>
    );
  }

  return (
    <div className="flex flex-col h-[600px]">
      {otherUserName && (
        <div className="p-4 border-b flex items-center gap-3">
          <Avatar className="h-8 w-8">
            <AvatarImage src={otherUserPicture} alt={otherUserName} />
            <AvatarFallback>{otherUserName[0]}</AvatarFallback>
          </Avatar>
          <h2 className="text-lg font-semibold">{otherUserName}</h2>
        </div>
      )}
      <ScrollArea className="flex-1 p-4">
        <div className="space-y-4">
          {localMessages.map((msg, index) => (
            <Card
              key={msg.id || index}
              className={`p-4 max-w-[80%] ${
                msg.sender_id === currentUserId
                  ? "ml-auto bg-primary text-primary-foreground"
                  : "mr-auto bg-muted"
              }`}
            >
              <p>{msg.content}</p>
              <span className="text-xs opacity-70">
                {new Date(msg.timestamp).toLocaleTimeString()}
              </span>
            </Card>
          ))}
          <div ref={messagesEndRef} />
        </div>
      </ScrollArea>
      <div className="p-4 border-t flex gap-2">
        <Textarea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Type your message..."
          className="flex-1 resize-none h-20"
          onKeyPress={(e) => {
            if (e.key === "Enter" && !e.shiftKey) {
              e.preventDefault();
              handleSendMessage();
            }
          }}
        />
        <Button onClick={handleSendMessage}>Send</Button>
      </div>
    </div>
  );
};