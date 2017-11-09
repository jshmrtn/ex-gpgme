defmodule ExGpgme.ContextTest do
  @moduledoc false

  use ExUnit.Case
  alias ExGpgme.Context
  ExGpgme.Results.{VerificationResult, Signature}

  doctest Context, except: [
    from_protocol: 1,
    from_protocol!: 1,
    import: 2,
    find_key: 2,
    find_key!: 2,
    encrypt: 4,
    sign_and_encrypt: 4,
    engine_info: 1,
    delete_key: 2,
    delete_secret_key: 2,
    decrypt: 2,
    sign: 3,
    verify_opaque: 3,
  ]

  @sender_fingerprint "95E9 3F47 0BCB 2E96 C648  572D FBFA 8591 3EE0 5E95"
  @sender_secret_key File.read!("priv/test/keys/sender_secret.asc")
  @sender_public_key File.read!("priv/test/keys/sender_public.asc")

  @receiver_fingerprint "9D8A 23BA DCFA 63B5 8B3B  1CED 3910 6283 1D08 8C71"
  @receiver_secret_key File.read!("priv/test/keys/receiver_secret.asc")
  @receiver_public_key File.read!("priv/test/keys/receiver_public.asc")

  @keychain_base_dir "priv/test/keychains/"

  @encrypted_receiver File.read!("priv/test/test_data/encrypted_receiver.asc")

  setup_all do
    @keychain_base_dir
    |> File.ls!
    |> Enum.reject(fn file ->
      file == ".gitkeep"
    end)
    |> Enum.each(fn file ->
      File.rm_rf!(@keychain_base_dir <> file)
    end)

    :ok
  end

  setup(tags) do
    context = if tags[:context] do
      dirname = :erlang.crc32("#{inspect make_ref()}")
      path = "priv/test/keychains/#{dirname}"

      File.mkdir!(path)
      File.chmod!(path, 0o700)

      on_exit fn ->
        File.rm_rf!(path)
      end

      context = Context.from_protocol!(:open_pgp)
      Context.set_pinentry_mode!(context, :loopback)
      Context.set_engine_home_dir!(context, path)

      if tags[:import_all] || tags[:import_sender_secret] do
        Context.import!(context, @sender_secret_key)
      end
      if tags[:import_sender_public] do
        Context.import!(context, @sender_public_key)
      end
      if tags[:import_all] || tags[:import_receiver_secret] do
        Context.import!(context, @receiver_secret_key)
      end
      if tags[:import_receiver_public] do
        Context.import!(context, @receiver_public_key)
      end

      if tags[:armor] do
        Context.set_armor(context, tags[:armor])
      end

      context
    end

    {:ok, %{context: context}}
  end

  describe "from_protocol/1" do
    protocols = [
      {:open_pgp, :ref},
      {:cms, :ref},
      {:gpg_conf, :ref},
      {:assuan, :ref},
      {:g13, :ref},
      {:ui_server, :ref},
      {:spawn, :ref},
      {:default, :error},
      {:unknown, :error},
      {{:other, 17}, :error},
    ]

    for {protocol, expected_result} <- protocols do
      test "uses correct constant for #{inspect protocol}" do
        protocol = unquote(protocol)

        result = Context.from_protocol(protocol)

        case unquote(expected_result) do
          :ref ->
            assert {:ok, ref} = result
            assert is_reference(ref)
          :error ->
            assert {:error, "Invalid value"} = result
        end
      end
    end

    test "gives argument error on wrong params" do
      assert_raise ArgumentError, fn ->
        Context.from_protocol(:foo)
      end
      assert_raise ArgumentError, fn ->
        Context.from_protocol("foo")
      end
      assert_raise ArgumentError, fn ->
        Context.from_protocol({:foo, 17})
      end
    end
  end

  describe "protocol/1" do
    @tag context: true
    test "gives protocol", %{context: context} do
      assert :open_pgp = Context.protocol(context)
    end
  end

  describe "import/2" do
    @tag context: true
    test "imports keys", %{context: context} do
      assert {:ok, %ExGpgme.Results.ImportResult{imports: imports}} =
        Context.import(context, @sender_public_key)

      assert 1 = Enum.count(imports)
    end
  end

  describe "import!/2" do
    @tag context: true
    test "imports keys", %{context: context} do
      assert %ExGpgme.Results.ImportResult{imports: imports} =
        Context.import!(context, @sender_public_key <> "\n" <> @receiver_public_key)

      assert 2 = Enum.count(imports)
    end
  end

  describe "find_key/2" do
    @tag context: true, import_sender_public: true
    test "finds key", %{context: context} do
      assert {:ok, ref} = Context.find_key(context, @sender_fingerprint)
      assert is_reference(ref)
    end

    @tag context: true
    test "errors with missing key", %{context: context} do
      assert {:error, "End of file"} = Context.find_key(context, "not existing fingerprint")
    end
  end

  describe "find_key!/2" do
    @tag context: true, import_sender_public: true
    test "finds key", %{context: context} do
      assert ref = Context.find_key!(context, @sender_fingerprint)
      assert is_reference(ref)
    end

    @tag context: true
    test "errors with missing key", %{context: context} do
      assert {:error, "End of file"} = Context.find_key(context, "not existing fingerprint")
    end
  end

  describe "encrypt/2" do
    @tag context: true, import_receiver_secret: true, armor: true
    test "encrypts correctly", %{context: context} do
      assert recipient = Context.find_key!(context, @receiver_fingerprint)

      assert {:ok, cyphertext} = Context.encrypt(context, [recipient], "Hello World!", [:always_trust])

      assert is_binary(cyphertext)
      assert cyphertext =~ "-BEGIN PGP MESSAGE-"
      assert cyphertext =~ "-END PGP MESSAGE-"

      assert {:ok, "Hello World!"} = Context.decrypt(context, cyphertext)
    end

    @tag context: true
    test "errors with missing key", %{context: context} do
      assert_raise ArgumentError, fn ->
        Context.encrypt(context, [], "Hello World!")
      end
    end
  end

  describe "decrypt/2" do
    @tag context: true, import_receiver_secret: true, armor: true
    test "decrypts correctly", %{context: context} do
      assert {:ok, "Hello World!"} = Context.decrypt(context, @encrypted_receiver)
    end
  end

  describe "armor?/1" do
    @tag context: true
    test "read correctly", %{context: context} do
      Context.set_armor(context, true)
      assert Context.armor?(context)
    end
  end

  describe "set_armor/2" do
    @tag context: true
    test "set correctly", %{context: context} do
      Context.set_armor(context, true)
      assert Context.armor?(context)

      Context.set_armor(context, false)
      refute Context.armor?(context)
    end
  end

  describe "text_mode?/1" do
    @tag context: true
    test "read correctly", %{context: context} do
      Context.set_text_mode(context, true)
      assert Context.text_mode?(context)
    end
  end

  describe "set_text_mode/1" do
    @tag context: true
    test "set correctly", %{context: context} do
      Context.set_text_mode(context, true)
      assert Context.text_mode?(context)

      Context.set_text_mode(context, false)
      refute Context.text_mode?(context)
    end
  end

  describe "delete_key/2" do
    @tag context: true, import_receiver_public: true
    test "really deletes key", %{context: context} do
      assert {:ok, key} = Context.find_key(context, @receiver_fingerprint)
      assert :ok = Context.delete_key(context, key)
      assert {:error, "End of file"} = Context.find_key(context, @receiver_fingerprint)
    end
  end

  describe "delete_secret_key/2" do
    @tag context: true, import_receiver_secret: true, manual_pinentry: true
    test "really deletes key", %{context: context} do
      assert {:ok, key} = Context.find_key(context, @receiver_fingerprint)
      Context.set_pinentry_mode!(context, :default)
      assert :ok = Context.delete_secret_key(context, key)
      assert {:error, "End of file"} = Context.find_key(context, @receiver_fingerprint)
    end
  end

  describe "sign/3" do
    @tag context: true, import_receiver_secret: true, armor: true
    test "creates correct signature", %{context: context} do
      assert {:ok, signature} = Context.sign(context, "Hello World")
      assert verification = Context.verify_opaque!(context, signature, "Hello World")
      assert %VerificationResult{signatures: [signature_result]} = verification
      assert %Signature{status: :valid} = signature_result
    end
  end
end
