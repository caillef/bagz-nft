interface Props {
  onClick: () => void
}

export const MintButton = ({ onClick }: Props) => (
  <button
    type="button"
    onClick={onClick}
    className="cta-button connect-wallet-button"
  >
    Mint NFT
  </button>
)
