export default function LoginPage() {
  return (
    <div style={{ padding: '2rem', maxWidth: '400px', margin: '0 auto' }}>
      <h1>Login</h1>
      <p>Magic link login will be implemented in T1</p>
      <form>
        <input
          type="email"
          placeholder="Enter your email"
          style={{ width: '100%', padding: '0.5rem', marginBottom: '1rem' }}
        />
        <button
          type="submit"
          style={{ width: '100%', padding: '0.5rem' }}
        >
          Send Magic Link
        </button>
      </form>
    </div>
  )
}
