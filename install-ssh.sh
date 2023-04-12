for port in {2221..2223}; do
  ssh-copy-id -p "$port" docker@127.0.0.1
done
