# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit versionator

DESCRIPTION="Qt5 documentation, for use with Qt Creator and other tools"
HOMEPAGE="https://doc.qt.io/"

PV_FULL=${PV/_p/-0-}
PV_NODOTS=$(get_version_component_range 1)$(get_version_component_range 2)$(get_version_component_range 3)
BASE_URI="https://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_${PV_NODOTS}_src_doc_examples/qt.${PV_NODOTS}.doc"
SRC_URI="${BASE_URI}/${PV_FULL}qt-everywhere-documentation.7z
	charts? ( ${BASE_URI}.qtcharts/${PV_FULL}qtcharts-documentation.7z )
	datavis? ( ${BASE_URI}.qtdatavis3d/${PV_FULL}qtdatavisualization-documentation.7z )
	networkauth? ( ${BASE_URI}.qtnetworkauth/${PV_FULL}qtnetworkauth-documentation.7z )
	script? ( ${BASE_URI}.qtscript/${PV_FULL}qtscript-documentation.7z
		${BASE_URI}.qtscript/${PV_FULL}qtscripttools-documentation.7z )
	speech? ( ${BASE_URI}.qtspeech/${PV_FULL}qtspeech-documentation.7z )
	virtualkeyboard? ( ${BASE_URI}.qtvirtualkeyboard/${PV_FULL}qtvirtualkeyboard-documentation.7z )
	webengine? ( ${BASE_URI}.qtwebengine/${PV_FULL}qtwebengine-documentation.7z )
"

LICENSE="FDL-1.3"
SLOT="5"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"

IUSE="3d bluetooth charts datavis declarative graphicaleffects +html location
	multimedia networkauth +qch script sensors speech virtualkeyboard webengine"
REQUIRED_USE="|| ( html qch )"

DEPEND="app-arch/p7zip"

S=${WORKDIR}/Docs/Qt-${PV%_p*}

src_prepare() {
	default

	# bug 597026
	rm -r global || die

	# bug 602750
	rm Makefile || die

	use 3d || rm -r qt3d* || die
	use bluetooth || rm -r qtbluetooth* || die
	use declarative || rm -r qtqml* qtquick* || die
	use graphicaleffects || rm -r qtgraphicaleffects* || die
	use location || rm -r qtlocation* || die
	use multimedia || rm -r qtmultimedia* || die
	use sensors || rm -r qtsensors* || die
}

src_install() {
	# must be the same as QT_INSTALL_DOCS
	local dest=/usr/share/doc/qt-${PV%_p*}
	insinto "${dest}"
	use html && doins -r */
	use qch && doins *.qch
	docompress -x "${dest}"
}
