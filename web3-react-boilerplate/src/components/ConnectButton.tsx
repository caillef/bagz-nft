interface Props {
  onClick: () => void
}

export const ConnectButton = ({ onClick }: Props) => (
  <button
    type="button"
    onClick={onClick}
    className="cta-button connect-wallet-button"
  >
    Connect to Wallet
  </button>
)
