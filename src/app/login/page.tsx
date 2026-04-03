'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';

export default function LoginPage() {
  const { user, loading, authEnabled, signIn, signUp, signInWithGoogle } = useAuth();
  const router = useRouter();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!loading && user) router.replace('/');
  }, [user, loading, router]);

  if (!authEnabled) {
    return (
      <div className="flex-1 flex items-center justify-center px-4">
        <div className="text-[11px] text-text-tertiary text-center">
          <div className="text-accent-red mb-2">$ error: auth not configured</div>
          <div>Set NEXT_PUBLIC_FIREBASE_* env vars to enable auth.</div>
        </div>
      </div>
    );
  }

  if (loading || user) return null;

  const friendlyError = (err: unknown): string => {
    const msg = err instanceof Error ? err.message : String(err);
    const code = msg.match(/\(auth\/([^)]+)\)/)?.[1];
    const map: Record<string, string> = {
      'invalid-email': 'Invalid email address',
      'user-disabled': 'Account has been disabled',
      'user-not-found': 'No account found with this email',
      'wrong-password': 'Incorrect password',
      'invalid-credential': 'Invalid email or password',
      'email-already-in-use': 'An account with this email already exists',
      'weak-password': 'Password must be at least 6 characters',
      'popup-closed-by-user': 'Sign-in popup was closed',
      'cancelled-popup-request': 'Sign-in cancelled',
      'network-request-failed': 'Network error — check your connection',
    };
    return code ? (map[code] || code.replace(/-/g, ' ')) : msg;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      if (isSignUp) {
        await signUp(email, password);
      } else {
        await signIn(email, password);
      }
    } catch (err: unknown) {
      setError(friendlyError(err));
    } finally {
      setSubmitting(false);
    }
  };

  const handleGoogle = async () => {
    setError('');
    try {
      await signInWithGoogle();
    } catch (err: unknown) {
      setError(friendlyError(err));
    }
  };

  return (
    <div className="flex-1 flex flex-col">
      {/* Terminal header */}
      <div className="px-4 py-3 bg-bg-secondary border-b border-border-primary">
        <div className="flex items-center gap-1.5 text-[11px]">
          <span className="text-accent-green">user</span>
          <span className="text-text-tertiary">@</span>
          <span className="text-accent-cyan">init.habits</span>
          <span className="text-text-tertiary">:~$</span>
          <span className="text-text-secondary ml-1">auth.{isSignUp ? 'signup' : 'login'}()</span>
        </div>
      </div>

      <div className="flex-1 flex flex-col justify-center px-4 py-8">
        <div className="text-[10px] text-text-tertiary mb-1">// {isSignUp ? 'create account' : 'authenticate'}</div>
        <div className="text-[16px] text-accent-green font-medium mb-6">
          {isSignUp ? '$ create_account' : '$ sign_in'}
        </div>

        {error && (
          <div className="mb-4 px-3 py-2 rounded-[4px] bg-accent-red/10 border border-accent-red/20">
            <div className="text-[10px] text-accent-red">stderr: {error}</div>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-3">
          <div>
            <label className="text-[10px] text-text-tertiary block mb-1">--email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              className="w-full bg-bg-input border border-border-primary rounded-[4px] px-3 py-2.5 text-[12px] text-text-primary placeholder:text-text-tertiary focus:outline-none focus:border-accent-green/40 transition-colors"
              placeholder="user@example.com"
            />
          </div>
          <div>
            <label className="text-[10px] text-text-tertiary block mb-1">--password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
              autoComplete={isSignUp ? 'new-password' : 'current-password'}
              className="w-full bg-bg-input border border-border-primary rounded-[4px] px-3 py-2.5 text-[12px] text-text-primary placeholder:text-text-tertiary focus:outline-none focus:border-accent-green/40 transition-colors"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="w-full py-2.5 rounded-[4px] bg-accent-green/15 text-accent-green border border-accent-green/30 text-[12px] font-medium hover:bg-accent-green/20 transition-colors disabled:opacity-50"
          >
            {submitting ? '$ processing...' : `$ sign_${isSignUp ? 'up' : 'in'} --email`}
          </button>
        </form>

        <div className="flex items-center gap-3 my-4">
          <div className="flex-1 h-px bg-border-primary" />
          <span className="text-[10px] text-text-tertiary">||</span>
          <div className="flex-1 h-px bg-border-primary" />
        </div>

        <button
          onClick={handleGoogle}
          className="w-full py-2.5 rounded-[4px] bg-bg-tertiary border border-border-primary text-[12px] text-text-secondary hover:bg-bg-tertiary/80 hover:text-text-primary transition-colors flex items-center justify-center gap-2"
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4"/>
            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18A10.96 10.96 0 001 12c0 1.77.42 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
          </svg>
          $ sign_in --google
        </button>

        <div className="mt-6 text-center">
          <button
            onClick={() => { setIsSignUp(!isSignUp); setError(''); }}
            className="text-[11px] text-text-tertiary hover:text-text-secondary transition-colors"
          >
            {isSignUp ? '// already have an account? sign_in' : '// need an account? sign_up'}
          </button>
        </div>
      </div>
    </div>
  );
}
