# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib toolchain-funcs

Sparse_PV="7.0.0"
Sparse_P="SuiteSparse-${Sparse_PV}"
DESCRIPTION="Unsymmetric multifrontal sparse LU factorization library"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${Sparse_PV}.tar.gz -> ${Sparse_P}.gh.tar.gz"

LICENSE="GPL-2+"
SLOT="0/6"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc openmp test"
RESTRICT="!test? ( test )"

DEPEND=">=sci-libs/suitesparseconfig-${Sparse_PV}
	>=sci-libs/amd-3.0.3
	>=sci-libs/cholmod-4.0.3[openmp=]
	virtual/blas"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

S="${WORKDIR}/${Sparse_P}/${PN^^}"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

multilib_src_configure() {
	# Fortran is only used to compile additional demo programs that can be tested.
	local mycmakeargs=(
		-DNSTATIC=ON
		-DNOPENMP=$(usex openmp OFF ON)
		-DNFORTRAN=ON
		-DDEMO=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	local demofiles=(
		umfpack_di_demo
		umfpack_dl_demo
		umfpack_zi_demo
		umfpack_zl_demo
	)
	for i in ${demofiles}; do
		./"${i}" > "${i}.out"
		diff --strip-trailing-cr "${S}/Demo/${i}.out" "${i}.out" || die "failed testing ${i}"
	done
}
multilib_src_install() {
	if use doc; then
		pushd "${S}/Doc"
		rm -rf *.pdf
		emake
		popd
		DOCS="${S}/Doc/*.pdf"
	fi
	cmake_src_install
}
