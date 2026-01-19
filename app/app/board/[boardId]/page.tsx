export default function BoardPage({
  params,
}: {
  params: { boardId: string }
}) {
  return (
    <div style={{ padding: '2rem' }}>
      <h1>Board: {params.boardId}</h1>
      <p>Board view with lists and cards will be implemented in T5</p>
    </div>
  )
}
