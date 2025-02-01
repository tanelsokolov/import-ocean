import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import Login from "@/pages/Login";
import Register from "@/pages/Register";
import Dashboard from "@/pages/Dashboard";
import Profile from "@/pages/Profile";
import Matches from "@/pages/Matches";
import Chats from "@/pages/Chats";
import { WebSocketProvider } from "./contexts/WebSocketContext";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <WebSocketProvider>
        <div className="min-h-screen">
          <Router>
            <Routes>
              <Route path="/" element={<Login />} />
              <Route path="/register" element={<Register />} />
              <Route
                path="/dashboard"
                element={
                  <RequireAuth>
                    <Dashboard />
                  </RequireAuth>
                }
              />
              <Route
                path="/profile"
                element={
                  <RequireAuth>
                    <Profile />
                  </RequireAuth>
                }
              />
              <Route
                path="/matches"
                element={
                  <RequireAuth>
                    <Matches />
                  </RequireAuth>
                }
              />
              <Route
                path="/chats"
                element={
                  <RequireAuth>
                    <Chats />
                  </RequireAuth>
                }
              />
            </Routes>
          </Router>
          <Toaster />
        </div>
      </WebSocketProvider>
    </QueryClientProvider>
  );
}

function RequireAuth({ children }: { children: JSX.Element }) {
  const token = localStorage.getItem("token");
  if (!token) {
    return <Navigate to="/" replace />;
  }
  return children;
}

export default App;