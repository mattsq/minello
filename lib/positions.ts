/**
 * Calculate a position value between two existing positions.
 * Used for inserting items in sortable lists.
 *
 * @param a - Position of item before, or null if inserting at start
 * @param b - Position of item after, or null if inserting at end
 * @returns New position value
 */
export function between(a: number | null, b: number | null): number {
  // If no item before, place before b
  if (a === null) {
    return (b ?? 0) - 1
  }

  // If no item after, place after a
  if (b === null) {
    return a + 1
  }

  // Place at midpoint
  const midpoint = (a + b) / 2

  // TODO: If midpoint equals a or b due to precision, trigger renormalization
  if (midpoint === a || midpoint === b) {
    console.warn('Position precision issue detected - consider renormalization')
  }

  return midpoint
}
