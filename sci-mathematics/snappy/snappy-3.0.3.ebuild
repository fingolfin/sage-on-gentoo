# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
PYTHON_REQ_USE="tk"
DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="SnapPy is for studying the topology and geometry of 3-manifolds"
HOMEPAGE="https://github.com/3-manifolds/SnapPy
	https://pypi.org/project/snappy/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2+ BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-python/cython[${PYTHON_USEDEP}]
	dev-python/cypari2[${PYTHON_USEDEP}]
	dev-python/ipython[${PYTHON_USEDEP}]
	virtual/opengl"
RDEPEND="${DEPEND}
	>=sci-mathematics/spherogram-2.1[${PYTHON_USEDEP}]
	>=sci-mathematics/plink-2.4.1[${PYTHON_USEDEP}]
	sci-mathematics/snappy_manifolds[${PYTHON_USEDEP}]
	sci-mathematics/FXrays[${PYTHON_USEDEP}]
	!!dev-python/snappy"
BDEPEND=""

distutils_enable_tests setup.py

src_prepare(){
	default
	# TODO completely unvendor togl.
	# Removing vendored togl binaries from the wrong archs
	if use amd64 || use linux-amd64 ; then
		rm -rf python/togl/darwin*
		rm -rf python/togl/win32*
	fi
}
