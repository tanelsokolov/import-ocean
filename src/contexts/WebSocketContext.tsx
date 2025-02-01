import React, { createContext, useContext, useEffect, useRef, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useToast } from '@/hooks/use-toast';

interface WebSocketContextType {
  connectWebSocket: (matchId: number) => void;
  sendMessage: (matchId: number, message: any) => void;
  isConnected: boolean;
}

const WebSocketContext = createContext<WebSocketContextType | null>(null);

export const WebSocketProvider = ({ children }: { children: React.ReactNode }) => {
  const wsRef = useRef<WebSocket | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  const maxRetries = 5;
  const [retryCount, setRetryCount] = useState(0);

  const connectWebSocket = (matchId: number) => {
    const token = localStorage.getItem('token');
    if (!token) {
      console.error('No authentication token found');
      return;
    }

    if (wsRef.current?.readyState === WebSocket.OPEN) {
      return;
    }

    const websocket = new WebSocket(`ws://localhost:3000/ws/chat/${matchId}?token=${token}`);
    
    websocket.onopen = () => {
      setIsConnected(true);
      setRetryCount(0);
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
    
    websocket.onmessage = (event) => {
      const newMessage = JSON.parse(event.data);
      // Invalidate both messages and notifications queries
      queryClient.invalidateQueries({ queryKey: ['messages'] });
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    };

    websocket.onclose = () => {
      setIsConnected(false);
      wsRef.current = null;

      if (retryCount < maxRetries) {
        const timeout = Math.min(1000 * Math.pow(2, retryCount), 10000);
        reconnectTimeoutRef.current = setTimeout(() => {
          setRetryCount(prev => prev + 1);
          connectWebSocket(matchId);
        }, timeout);
      } else {
        toast({
          title: "Connection Lost",
          description: "Unable to maintain chat connection. Please refresh the page.",
          variant: "destructive",
        });
      }
    };

    websocket.onerror = (error) => {
      console.error('WebSocket error:', error);
      toast({
        title: "Connection Error",
        description: "There was an error with the chat connection",
        variant: "destructive",
      });
    };

    wsRef.current = websocket;
  };

  const sendMessage = (matchId: number, message: any) => {
    if (!wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) {
      connectWebSocket(matchId);
      toast({
        title: "Connection Error",
        description: "Reconnecting to chat...",
        variant: "destructive",
      });
      return;
    }
    wsRef.current.send(JSON.stringify({ ...message, match_id: matchId }));
  };

  useEffect(() => {
    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      if (wsRef.current?.readyState === WebSocket.OPEN) {
        wsRef.current.close(1000, "Component unmounting");
      }
    };
  }, []);

  return (
    <WebSocketContext.Provider value={{ connectWebSocket, sendMessage, isConnected }}>
      {children}
    </WebSocketContext.Provider>
  );
};

export const useWebSocket = () => {
  const context = useContext(WebSocketContext);
  if (!context) {
    throw new Error('useWebSocket must be used within a WebSocketProvider');
  }
  return context;
};