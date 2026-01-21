interface ConnectionStatusProps {
  isConnected: boolean
}

export default function ConnectionStatus({ isConnected }: ConnectionStatusProps) {
  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: '0.5rem',
        fontSize: '0.875rem',
        color: isConnected ? '#059669' : '#6b7280',
      }}
    >
      <div
        style={{
          width: '8px',
          height: '8px',
          borderRadius: '50%',
          backgroundColor: isConnected ? '#10b981' : '#9ca3af',
          boxShadow: isConnected ? '0 0 4px rgba(16, 185, 129, 0.6)' : 'none',
        }}
      />
      <span style={{ fontWeight: '500' }}>
        {isConnected ? 'Live' : 'Connecting...'}
      </span>
    </div>
  )
}
