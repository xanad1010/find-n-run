#!/bin/bash

    # markdown: indent all lines four spaces for literal text.

    # The 'multi' source outputs maximum 500 records to the tree list
    # widget.  Each row displays its own icon, which is chosen in
    # alphabetical order from the icon cache.  The row label is the icon
    # name.  Activating a row brings up an Xdialog message with the numbered
    # icon name.  Handled error cases:
    #  1. Invalid/not found ICONCACHE directory.
    #  2. Empty icon cache.
    # Source title and error messages can be localized by installing a
    # suitable .mo file, findnrun-plugin-multi.mo

    term=$1 # search term
    title=$2
    max=500 # output records

    # Source declaration, manually copy to ~/findnrunrc {{{1
    TITLE_multi='multi-field example'
    SOURCE_multi='multi:multi::multi'
    TAP_multi='/usr/share/doc/findnrun/examples/multi-field-tap.sh "${term}" "${TITLE}" | findnrun-formatter --'
    DRAIN_multi='show() { Xdialog --msgbox "$*" 0x0 ;} ; show'

    # Trap {{{1
    TMPF="/tmp/${0##*/}.tmp.$$"
    trap 'rm -f ".${TMPF:-/tmp/dummy}"*' HUP INT QUIT TERM ABRT 0

    # i18n Localization {{{1
    TEXTDOMAIN="findnrun-plugin-multi"
    gettext "multi" >/dev/null # this source's TITLE

    # Load findnrun settings. {{{1
    ICONCACHE=
    . ${HOME}/.findnrunrc

    # Handle errors upfront. {{{1
    # But only when the input search field is "", which happens in two
    # cases: 1) the first time the source plugin is started, typically by
    # pressing F3; and 2) when the user clears the search input field.
    if [ -z "${term}" ]; then
      if ! [ -d "${ICONCACHE}" ]; then
        # Print error directly onto the list widget. {{{
        printf "$(gettext \
          "%sError: invalid setting: ICONCACHE.\n%sPlease try restarting Find'N'Run.")" \
          '||' '||' # 2 records
        #}}}
        exit
      fi
      # Our tap search targets the filename template findnrun-*.png only
      set +f # enable * expansion
      line=
      printf "%s\n" "${ICONCACHE}/findnrun"-*.png >"${TMPF}" && # list icon filenames
        read line < "${TMPF}" # read first filename
      if case "${line}" in *-\*.png) true ;; *) false ;; esac; then
        # Error: no matching filename. {{{
        # i18n [%s] is 'Show all icons' in TEXTDOMAIN=findnrun.
        # i18n '%s' is the source TITLE in TEXTDOMAIN=findnrun-plugin-multi.
        printf "$(gettext \
          "%sNo icons?\n%sPlease untick [%s] and tick it again.\n%sThen refresh the list for source '%s'.")" \
          '||' '||' "$(gettext -d findnrun "_Show all icons")" '||' "${title}" # 3 records
        #}}}
        exit
      fi
    fi

    # Implement the search. {{{1
    # Output tabular data {{{2
    # Fill six columns:
    # <icon-filename> '|' <tap-reserved> '|' <label> '|' <tap-data> '|' <comment> '|' <categories>

    d=/dev/fd

    # This is one way to fill six columns worth of data. Each here-doc below
    # contains a column's worth of data. Sub-shells run in some here-docs to
    # create dynamic data.
    paste -d '|' $d/4 4<<EOF4 $d/5 5<<EOF5 $d/6 6<<EOF6 $d/7 7<<EOF7 $d/8 8<<EOF8 $d/9 9<<EOF9
    $(
      # Save icon names to ${TMPF}.4
      set +f # enable * expansion
      # List icon filenames that match the search term.
      printf "%s\n" "${ICONCACHE}/findnrun-"*"$1"*.png >"${TMPF}.4" &&
      # Format filenames.
      awk '
      {
        # Exit on reaching the maximum output record count.
        if( ++n > '"$max"') exit

        # Take basename and print to this column (EOF4).
        gsub(/^.*\/|\.png$/, ""); print

        # Strip name template prefix and print to file for column EOF6.
        print substr($0, 1+length("findnrun-")) > "'"${TMPF}.6"'"
      } ' "${TMPF}.4"
    )
EOF4
    tap-reserved
EOF5
$( # markdown: this line not indented to prevent spurious output.
      # Print labels courtesy of column EOF4.
      cat "${TMPF}.6"
)
EOF6
    $(
      # Source drain will process these data.
      # Output a numbered list of icon names for Xdialog to show on row activation.
      cat -n "${TMPF}.6"
    )
EOF7
    comments
EOF8
    categories
EOF9

