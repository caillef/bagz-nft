interface Props {
  name: string
  quantity: number
}

interface ItemIcons {
  [key: string]: string
}

const ITEM_ICONS: ItemIcons = {
  Stone: '/icons/stone.png',
  Stick: '/icons/stick.png',
  Gear: '/icons/gear.png',
  Diamond: '/icons/diamond.png',
}

export const Item = ({ name, quantity }: Props) => (
  <div className="item">
    {quantity > 0 && (
      <div>
        <img alt={name} src={ITEM_ICONS[name]} />
        <span>{quantity}</span>
      </div>
    )}
  </div>
)
