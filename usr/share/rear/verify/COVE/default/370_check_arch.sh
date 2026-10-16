#
# Check that architecture is the same on the source and target systems
#

function normalize_arch() {
    local arch="$1"
    case "$arch" in
        (arm)
            arch="ARM64"
            ;;
        (i386)
            arch="x86_64"
            ;;
    esac
    echo "$arch"
}

target_arch=$(normalize_arch "$MACHINE")

source_arch=$(normalize_arch "${ARCH##*-}")

text="Architecture mismatch detected. The source system architecture is ${source_arch}, \
while the target system architecture is ${target_arch}. Mismatched architectures are not allowed. \
Please use a target system with the ${source_arch} architecture."

if [ "$source_arch" != "$target_arch" ] ; then
    cove_print_in_frame "ERROR" "$text"
    Error "Architecture mismatch detected."
fi

unset -v target_arch source_arch text
unset -f normalize_arch
