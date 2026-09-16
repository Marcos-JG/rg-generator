export default function Button({ children, onClick, variant = 'primary', className = '', ...props }) {
  const base = 'studio-button px-4 py-2 font-medium transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed';
  const variants = {
    primary: 'studio-button-primary',
    secondary: 'studio-button-secondary',
    danger: 'bg-red-600 text-white hover:bg-red-700',
    ghost: 'bg-transparent text-gray-600 hover:bg-gray-100',
  };

  return (
    <button
      onClick={onClick}
      className={`${base} ${variants[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
