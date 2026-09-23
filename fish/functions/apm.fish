# apm - grab Arch Linux packages on Windows (fish under Git for Windows)
#
#   apm search <query>   search official repos + AUR
#   apm info   <name>    show metadata for an official package
#   apm get    <name>    download the official binary .pkg.tar.zst
#   apm get -x <name>    download + extract in place
#   apm src    <name>    download the AUR source snapshot (PKGBUILD etc.)
#
# Arch packages are just .pkg.tar.zst archives, so GNU tar can unpack them.
# The binaries inside are Linux ELF, so use WSL to actually run them.

function apm -d "Download Arch Linux pacman packages"
    set -l action "$argv[1]"
    set -e argv[1]

    switch "$action"
        case search
            __apm_search $argv
        case info
            __apm_info $argv
        case get
            __apm_get $argv
        case src
            __apm_src $argv
        case help -h --help ''
            __apm_help
        case '*'
            echo "apm: unknown action '$action'" >&2
            echo "usage: apm help" >&2
            return 1
    end
end

# Find a curl that actually runs. Git's /usr/bin/curl can be a dead MSYS
# binary; /mingw64/bin/curl and Windows' System32 curl are reliable.
function __apm_curlcmd
    if set -q __apm_curl
        echo $__apm_curl
        return 0
    end
    for c in /mingw64/bin/curl.exe /usr/bin/curl.exe /c/Windows/System32/curl.exe curl
        if command -s $c >/dev/null 2>&1
            set -g __apm_curl $c
            echo $c
            return 0
        end
    end
    echo "apm: no working curl found" >&2
    return 1
end

function __apm_hsize -a bytes
    if test -n "$bytes"; and test "$bytes" -ge 1048576
        echo (math -s1 "$bytes / 1048576.0")MiB
    else if test -n "$bytes"
        echo (math -s0 "$bytes / 1024.0")KiB
    else
        echo "?"
    end
end

function __apm_search
    set -l q "$argv[1]"
    test -n "$q"; or begin
        echo "apm search: missing query" >&2
        return 1
    end

    set -l curl (__apm_curlcmd); or return 1

    echo "== official repositories =="
    set -l json ($curl -fsS "https://archlinux.org/packages/search/json/?q=$q" 2>/dev/null)
    if test -n "$json"
        set -l names (string match -arg '"pkgname": ?"([^"]*)"' "$json")
        set -l repos (string match -arg '"repo": ?"([^"]*)"' "$json")
        set -l vers (string match -arg '"pkgver": ?"([^"]*)"' "$json")
        for i in (seq (count $names))
            printf '  %-9s %-24s %s\n' "$repos[$i]" "$names[$i]" "$vers[$i]"
        end
    else
        echo "  (no matches)"
    end

    echo "== AUR =="
    set -l aur ($curl -fsS "https://aur.archlinux.org/rpc/v5/search/$q" 2>/dev/null)
    if test -n "$aur"
        set -l an (string match -arg '"Name":"([^"]*)"' "$aur")
        set -l av (string match -arg '"Version":"([^"]*)"' "$aur")
        set -l am (string match -arg '"Maintainer":"([^"]*)"|"Maintainer":null' "$aur")
        for i in (seq (count $an))
            if test -n "$am[$i]"
                printf '  %-24s %-20s by %s\n' "$an[$i]" "$av[$i]" "$am[$i]"
            else
                printf '  %-24s %-20s (orphaned)\n' "$an[$i]" "$av[$i]"
            end
        end
    else
        echo "  (no matches)"
    end
end

function __apm_info
    set -l name "$argv[1]"
    test -n "$name"; or begin
        echo "apm info: missing package name" >&2
        return 1
    end

    set -l curl (__apm_curlcmd); or return 1

    set -l json ($curl -fsS "https://archlinux.org/packages/search/json/?name=$name")
    set -l n (string match -arg '"pkgname": ?"([^"]*)"' "$json")
    if test -z "$n"
        echo "no such package in official repos (try: apm search $name)" >&2
        return 1
    end

    set -l repos (string match -arg '"repo": ?"([^"]*)"' "$json")
    set -l archs (string match -arg '"arch": ?"([^"]*)"' "$json")
    set -l vers (string match -arg '"pkgver": ?"([^"]*)"' "$json")
    set -l rels (string match -arg '"pkgrel": ?"([^"]*)"' "$json")
    set -l descs (string match -arg '"pkgdesc": ?"([^"]*)"' "$json")
    set -l files (string match -arg '"filename": ?"([^"]*)"' "$json")
    set -l csis (string match -arg '"compressed_size": ?([0-9]+)' "$json")

    for i in (seq (count $n))
        echo "name    $n[$i]"
        echo "repo    $repos[$i]"
        echo "version $vers[$i]-$rels[$i]"
        echo "arch    $archs[$i]"
        echo "size    $(__apm_hsize $csis[$i])"
        echo "desc    $descs[$i]"
        echo "file    $files[$i]"
        echo
    end
end

function __apm_get
    set -l extract 0
    if contains -- -x $argv
        set extract 1
    end
    set -l args (string match -v -- -x $argv)
    set -l name "$args[1]"
    test -n "$name"; or begin
        echo "apm get: missing package name" >&2
        return 1
    end

    set -l curl (__apm_curlcmd); or return 1

    set -l json ($curl -fsS "https://archlinux.org/packages/search/json/?name=$name")
    set -l files (string match -arg '"filename": ?"([^"]*)"' "$json")
    if test -z "$files"
        echo "apm: '$name' not in official repos, falling back to AUR source..." >&2
        __apm_src "$name"
        return $status
    end

    set -l repos (string match -arg '"repo": ?"([^"]*)"' "$json")
    set -l archs (string match -arg '"arch": ?"([^"]*)"' "$json")
    set -l csis (string match -arg '"compressed_size": ?([0-9]+)' "$json")

    for i in (seq (count $files))
        set -l f "$files[$i]"
        set -l url "https://geo.mirror.pkgbuild.com/$repos[$i]/os/$archs[$i]/$f"
        echo "==> $repos[$i]/$archs[$i] $f ($(__apm_hsize $csis[$i]))"
        $curl -fSL --progress-bar -o "$f" "$url"
        if test $status -ne 0
            echo "apm get: download failed" >&2
            return 1
        end
        if test $extract -eq 1
            echo "==> extracting $f"
            tar --zstd -xf "$f"
        end
    end
end

function __apm_src
    set -l name "$argv[1]"
    test -n "$name"; or begin
        echo "apm src: missing package name" >&2
        return 1
    end

    set -l curl (__apm_curlcmd); or return 1

    set -l json ($curl -fsS "https://aur.archlinux.org/rpc/v5/info/$name")
    set -l found (string match -arg '"Name":"([^"]*)"' "$json")
    if test -z "$found"
        echo "apm: '$name' not found in AUR" >&2
        return 1
    end

    echo "==> AUR source snapshot for $name"
    $curl -fSL --progress-bar -o "$name.tar.gz" "https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz"
    if test $status -ne 0
        echo "apm src: download failed" >&2
        return 1
    end
    echo "==> unpacking"
    tar -xzf "$name.tar.gz"
end

function __apm_help
    echo "apm - download Arch Linux packages without pacman"
    echo
    echo "usage:"
    echo "  apm search <query>   search official repos + AUR"
    echo "  apm info   <name>    show metadata for an official package"
    echo "  apm get    <name>    download the official binary .pkg.tar.zst"
    echo "  apm get -x <name>    download + extract in place"
    echo "  apm src    <name>    download the AUR source snapshot"
    echo
    echo "note: binaries inside packages are Linux ELF; run them via WSL."
end