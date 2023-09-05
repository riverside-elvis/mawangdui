# Build the ebook. Check build.md to prep build environment.

# Check arg.
case $1 in
    epub) echo "Building $1" ;;
    pdf) echo "Building $1" ;;
    *) echo "Usage: $0 [epub|pdf]" > /dev/stderr && exit 1
esac

# Pre-process foreward template version.
if [[ -n $(git status -s) ]]; then
    COMMIT="#######"
    EPOCH=$(date +%s)
else
    COMMIT=$(git log -1 --format=%h)
    EPOCH=$(git log -1 --format=%ct)
    TAG=$(git describe --tags --candidates=0 $COMMIT 2>/dev/null)
    if [[ -n $TAG ]]; then
        COMMIT=$TAG
    fi
fi
DATE="@$EPOCH"
VERSION="Commit $COMMIT, $(date -d $DATE +'%B %d, %Y')."
sed "s/{{ version }}/$VERSION/g" foreward.tpl.md > foreward.md
echo "${VERSION}"

# Pre-process input files.
MD="MawangduiLaozi-$COMMIT.md"
sed -s '$G' -s \
    foreward.md \
    de-01-r38.md \
    de-02-r39.md \
    de-03-r41.md \
    de-04-r40.md \
    de-05-r42.md \
    de-06-r43.md \
    de-07-r44.md \
    de-08-r45.md \
    de-09-r46.md \
    de-10-r47.md \
    de-11-r48.md \
    de-12-r49.md \
    de-13-r50.md \
    de-14-r51.md \
    de-15-r52.md \
    de-16-r53.md \
    de-17-r54.md \
    de-18-r55.md \
    de-19-r56.md \
    de-20-r57.md \
    de-21-r58.md \
    de-22-r59.md \
    de-23-r60.md \
    de-24-r61.md \
    de-25-r62.md \
    de-26-r63.md \
    de-27-r64.md \
    de-28-r65.md \
    de-29-r66.md \
    de-30-r80.md \
    de-31-r81.md \
    de-32-r67.md \
    de-33-r68.md \
    de-34-r69.md \
    de-35-r70.md \
    de-36-r71.md \
    de-37-r72.md \
    de-38-r73.md \
    de-39-r74.md \
    de-40-r75.md \
    de-41-r76.md \
    de-42-r77.md \
    de-43-r78.md \
    de-44-r79.md \
    dao-01-r01.md \
    dao-02-r02.md \
    dao-03-r03.md \
    dao-04-r04.md \
    dao-05-r05.md \
    dao-06-r06.md \
    dao-07-r07.md \
    dao-08-r08.md \
    dao-09-r09.md \
    dao-10-r10.md \
    dao-11-r11.md \
    dao-12-r12.md \
    dao-13-r13.md \
    dao-14-r14.md \
    dao-15-r15.md \
    dao-16-r16.md \
    dao-17-r17r18.md \
    dao-18-r19.md \
    dao-19-r20.md \
    dao-20-r21.md \
    dao-21-r24.md \
    dao-22-r22.md \
    dao-23-r23.md \
    dao-24-r25.md \
    dao-25-r26.md \
    dao-26-r27.md \
    dao-27-r28.md \
    dao-28-r29.md \
    dao-29-r30.md \
    dao-30-r31.md \
    dao-31-r32.md \
    dao-32-r33.md \
    dao-33-r34.md \
    dao-34-r35.md \
    dao-35-r36.md \
    dao-36-r37.md \
    README.md \
    notes.md > "$MD"

# Build epub.
if [ $1 = "epub" ]; then
    EPUB="MawangduiLaozi-$COMMIT.epub"
    HTML="MawangduiLaozi-$COMMIT.html.md"
    CJK_FONT="/usr/share/fonts/opentype/noto/NotoSerifCJK-Light.ttc"
    CJK_OUT="epub-fonts/CJK.ttf"
    python epub_fonts.py "$MD" "$CJK_FONT" "$CJK_OUT" cjk
    bash epub-html.bash "$MD" > "$HTML"
    pandoc "$HTML" \
        --defaults epub-defaults.yaml \
        --output "${EPUB}"
    echo Built "${EPUB}"
fi

## Or build pdf.
if [ $1 = "pdf" ]; then
    PDF="MawangduiLaozi-$COMMIT.pdf"
    TEX="MawangduiLaozi-$COMMIT.tex.md"
    bash pdf-latex.bash "$MD" > "$TEX"
    pandoc "$TEX" \
        --defaults pdf-defaults.yaml \
        --output "${PDF}"
    echo Built "${PDF}"
fi
