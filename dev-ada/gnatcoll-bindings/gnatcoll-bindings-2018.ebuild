# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit multilib multiprocessing python-single-r1

MYP=${PN}-gpl-${PV}

DESCRIPTION="GNAT Component Collection"
HOMEPAGE="http://libre.adacore.com"
SRC_URI="http://mirrors.cdn.adacore.com/art/5b0ce9cfc7a4475261f97ca5
	-> ${MYP}-src.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnat_2016 gnat_2017 +gnat_2018 gmp iconv python readline +shared
	static-libs static-pic syslog"

RDEPEND="python? ( ${PYTHON_DEPS} )
	dev-ada/gnatcoll-core[gnat_2016=,gnat_2017=,gnat_2018=]
	dev-ada/gnatcoll-core[shared?,static-libs?,static-pic?]
	gmp? ( dev-libs/gmp:* )"
DEPEND="${RDEPEND}
	dev-ada/gprbuild[gnat_2016=,gnat_2017=,gnat_2018=]"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} ) !gnat_2016"

S="${WORKDIR}"/${MYP}-src

PATCHES=( "${FILESDIR}"/${P}-gentoo.patch )

src_compile() {
	if use gnat_2017; then
		GCC_VER=6.3.0
	else
		GCC_VER=7.3.1
	fi
	build () {
		GCC=${CHOST}-gcc-${GCC_VER} gprbuild -j$(makeopts_jobs) -m -p -v \
			-XLIBRARY_TYPE=$2 -P $1/gnatcoll_$1.gpr -XBUILD="PROD" \
			-XGNATCOLL_ICONV_OPT= -XGNATCOLL_PYTHON_CFLAGS="-I$(python_get_includedir)" \
			-XGNATCOLL_PYTHON_LIBS=$(python_get_library_path) \
			-cargs:Ada ${ADAFLAGS} -cargs:C ${CFLAGS} || die "gprbuild failed"
	}
	for kind in shared static-libs static-pic ; do
		if use $kind; then
			lib=${kind%-libs}
			lib=${lib/shared/relocatable}
			for dir in gmp iconv python readline syslog ; do
				if use $dir; then
					build $dir $lib
				fi
			done
		fi
	done
}

src_install() {
	build () {
		gprinstall -p -f -XBUILD=PROD --prefix="${D}"/usr -XLIBRARY_TYPE=$2 \
			-XGNATCOLL_ICONV_OPT= -P $1/gnatcoll_$1.gpr --build-name=$2
	}
	for kind in shared static-libs static-pic ; do
		if use $kind; then
			lib=${kind%-libs}
			lib=${lib/shared/relocatable}
			for dir in gmp iconv python readline syslog ; do
				if use $dir; then
					build $dir $lib
				fi
			done
		fi
	done
	rm -r "${D}"/usr/share/gpr/manifests || die
	einstalldocs
}
