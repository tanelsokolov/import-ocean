import { useParams, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Header } from "@/components/Header";
import { apiRequest } from "@/lib/api";
import { Profile } from "@/types";
import { useToast } from "@/hooks/use-toast";

const UserProfile = () => {
  const { userId } = useParams();
  const navigate = useNavigate();
  const { toast } = useToast();

  const { data: profile, isLoading: isProfileLoading } = useQuery<Profile>({
    queryKey: ["profile", userId],
    queryFn: async () => {
      const response = await apiRequest(`/api/users/${userId}/profile`);
      return {
        ...response,
        lookingFor: response.looking_for,
      };
    },
    meta: {
      onError: () => {
        toast({
          variant: "destructive",
          title: "Error",
          description: "Failed to load profile. Please try again later."
        });
      }
    }
  });

  const { data: bioData, isLoading: isBioLoading } = useQuery<{ age: number; location: string }>({
    queryKey: ["bio", userId],
    queryFn: async () => apiRequest(`/api/users/${userId}/bio`),
  });

  const { data: userData, isLoading: isUserLoading, error } = useQuery<{ name: string; profilePictureUrl: string }>({
    queryKey: ["user", userId],
    queryFn: async () => {
      const response = await apiRequest(`/api/users/${userId}`);
      //console.log("User API Response:", response); // Debug log
      return {
        name: response.name,  
        profilePictureUrl: response.profile_picture_url,
      };
    },
  });
  
  

  if (isProfileLoading || isBioLoading || isUserLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-match-light/10 to-match-dark/10">
        <Header />
        <div className="max-w-2xl mx-auto p-8">
          <div>Loading...</div>
        </div>
      </div>
    );
  }

  if (!profile || !bioData || !userData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-match-light/10 to-match-dark/10">
        <Header />
        <div className="max-w-2xl mx-auto p-8">
          <div>User not found</div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-match-light/10 to-match-dark/10">
      <Header />
      <div className="max-w-2xl mx-auto p-8">
        <Card className="bg-white">
          <CardHeader>
            <div className="flex items-center gap-4">
              <Avatar className="h-20 w-20">
                <AvatarImage src={userData.profilePictureUrl || "/placeholder.svg"} alt={profile.name} />
                <AvatarFallback>{profile.name?.[0]}</AvatarFallback>
              </Avatar>
              <div>
              <h1 className="text-2xl font-bold">{userData.name}</h1>
                <p className="text-gray-600">Age: {bioData.age ?? "Not provided"}</p>
                <p className="text-gray-600">Location: {bioData.location ?? "Not specified"}</p>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-gray-700 mb-4">{profile.bio}</p>
            <h3 className="text-lg font-semibold">Interests</h3>
            <div className="flex flex-wrap gap-2 mt-2">
              {profile.interests?.map((interest) => (
                <span key={interest} className="px-3 py-1 bg-gray-200 rounded-full text-sm">
                  {interest}
                </span>
              ))}
            </div>
            <div className="mt-4">
              <h3 className="text-lg font-semibold">Looking For</h3>
              <p className="text-gray-700">{profile.lookingFor ?? "No preferences specified"}</p>
            </div>
            <div className="mt-4">
              <h3 className="text-lg font-semibold">Occupation</h3>
              <p className="text-gray-700">{profile.occupation}</p>
            </div>
            <div className="flex justify-end mt-6">
              <Button onClick={() => navigate(`/chats?user=${userId}`)}>Open Chat</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default UserProfile;