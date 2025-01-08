self: super:

{
  ktalk = (super.callPackage ./ktalk.nix { });
  fleeting-chat = (super.callPackage ./fleeting-chat.nix { });
}
