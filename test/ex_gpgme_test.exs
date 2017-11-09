# defmodule ExGpgmeTest do
#   use ExUnit.Case
#   doctest ExGpgme
#
#   @sender_fingerprint "95E9 3F47 0BCB 2E96 C648  572D FBFA 8591 3EE0 5E95"
#   @sender_secret_key File.read!("priv/test/sender_secret.asc")
#   #@sender_public_key File.read!("priv/test/sender_public.asc")
#   @receiver_fingerprint "9D8A 23BA DCFA 63B5 8B3B  1CED 3910 6283 1D08 8C71"
#   #@receiver_secret_key File.read!("priv/test/receiver_secret.asc")
#   @receiver_public_key File.read!("priv/test/receiver_public.asc")
#
#   defp reset_keys do
#     ExGpgme.delete_secret_key(@receiver_fingerprint)
#     ExGpgme.delete_secret_key(@sender_fingerprint)
#     ExGpgme.delete_key(@receiver_fingerprint)
#     ExGpgme.delete_key(@sender_fingerprint)
#   end
#
#   setup_all do
#     reset_keys()
#
#     tmp_dir = System.tmp_dir!()
#
#     on_exit fn ->
#       reset_keys()
#       File.rm_rf!(tmp_dir)
#     end
#
#     {:ok, %{tmp_dir: tmp_dir}}
#   end
#
#   test "encrypts stuff correctly", %{tmp_dir: tmp_dir} do
#     data = "foo"
#     {:ok, encrypted} = ExGpgme.encrypt(data, @sender_secret_key, @receiver_public_key)
#     encrypted_file = Path.join(tmp_dir, "encrypted")
#     File.write!(encrypted_file, encrypted, [:binary])
#
#     IO.inspect result.out
#   end
# end
