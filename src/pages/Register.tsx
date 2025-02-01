import { SignupForm } from "@/components/auth/SignupForm";

const Register = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8">
        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold text-gray-900">
            Create an account
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Start finding your perfect match today
          </p>
        </div>
        <SignupForm />
      </div>
    </div>
  );
};

export default Register;