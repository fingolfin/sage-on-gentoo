# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib fortran-2 toolchain-funcs

MY_PV=$(ver_rs 3 '-')
TOPNAME="SuiteSparse-${MY_PV}"
DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${MY_PV}.tar.gz -> ${TOPNAME}.gh.tar.gz"

LICENSE="GPL-2+"
SLOT="0/6"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc openmp test"
RESTRICT="!test? ( test )"

DEPEND="~sci-libs/suitesparseconfig-${PV}
	~sci-libs/amd-${PV}
	~sci-libs/cholmod-${PV}[openmp=]
	virtual/blas"
RDEPEND="${DEPEND}"
BDEPEND="doc? ( virtual/latex-base )"

S="${WORKDIR}/${TOPNAME}/${PN^^}"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

multilib_src_configure() {
	local mycmakeargs=(
		-DNSTATIC=ON
		-DDEMO=$(usex test)
		-DFDEMO=$(usex test)
	)
	cmake_src_configure
}

multilib_src_test() {
	# Run demo files
	./readhb_nozeros < "${S}"/Demo/HB/can_24.psa > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/can_24.psa > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb_nozeros < "${S}"/Demo/HB/west0067.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/west0067.rua > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb_nozeros < "${S}"/Demo/HB/fs_183_6.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/fs_183_6.rua > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb         < "${S}"/Demo/HB/fs_183_6.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/fs_183_6.rua > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb         < "${S}"/Demo/HB/arc130.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/arc130.rua > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb_nozeros < "${S}"/Demo/HB/arc130.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/arc130.rua > tmp_Asize || die "failed testing"
	./umf4 || die "failed testing"
	./readhb_nozeros < "${S}"/Demo/HB/arc130.rua > tmp_A || die "failed testing"
	./readhb_size    < "${S}"/Demo/HB/arc130.rua > tmp_Asize || die "failed testing"
	./umf4 a 1e-6 || die "failed testing"
	./umf4hb         < "${S}"/Demo/HB/west0067.rua > umf4hb.out || die "failed testing"
	./umf4zhb        < "${S}"/Demo/HB/qc324.cua > umf4zhb.out || die "failed testing"
	# The following diff statements should not be tested. Notes from previous
	# versions mentions they are unstable with toolchain and possibly arch.
	# And more importantly, upstream does not provide the .out file to compare with.
	#diff umf4hb.out "${S}"/Demo/umf4hb.out || die "failed testing"
	#diff umf4zhb.out "${S}"/Demo/umf4zhb.out || die "failed testing"
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
