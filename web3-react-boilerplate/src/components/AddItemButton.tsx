interface Props {
  onClick: () => void
  name: string
  quantity: number
}

export const AddItemButton = ({ onClick, name, quantity }: Props) => (
  <button type="button" onClick={onClick} className="additem-btn">
    Add {quantity} {name + (quantity > 1 ? 's' : '')}
  </button>
)
