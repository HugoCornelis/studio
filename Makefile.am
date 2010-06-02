##
## Neurospaces studio: a tool set for use with Neurospaces.
##

##############################################################################
##'
##' Neurospaces studio: a tool set for use with Neurospaces.
##'
##' Copyright (C) 1999-2008 Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################

SUBDIRS = perl tests

dist_bin_SCRIPTS = bin/neurospaces

RELEASE_MAJOR=`release-extract --major`
RELEASE_MINOR=`release-extract --minor`
RELEASE_MICRO=`release-extract --micro`

show-release-labels:
	echo "Release information (major-minor-micro): $(RELEASE_MAJOR).$(RELEASE_MINOR)-$(RELEASE_MICRO)"

dist-keywords:
	release-expand studio $(RELEASE_MAJOR) $(RELEASE_MINOR) $(RELEASE_MICRO) $(RELEASE_MAJOR).$(RELEASE_MINOR) hugo.cornelis@gmail.com --verbose
#	release-expand studio des 10 0 des-10 hugo.cornelis@gmail.com --verbose

dist-hook: 
	if test -n "$$NEUROSPACES_RELEASE" ; then cd $(srcdir) && if test -n "`mtn ls changed `" ; then false ; else true ; fi ; else true ; fi
#	release-expand studio $(RELEASE_MAJOR) $(RELEASE_MINOR) $(RELEASE_MICRO) $(RELEASE_MAJOR)-$(RELEASE_MINOR) hugo.cornelis@gmail.com --verbose
	find $(distdir) -name _Inline -exec chmod u+w -R \{\} \;
	$(RM) -fr `find $(distdir) -name _Inline`
	cp $(srcdir)/license.txt $(distdir)
#	cp -R $(srcdir)/docs $(distdir)
#	cp -a $(srcdir)/perl $(distdir)
	test -d $(distdir)/tests || mkdir $(distdir)/tests
	test -d $(distdir)/tests/specifications || mkdir $(distdir)/tests/specifications
	cp -R $(srcdir)/tests/tests_2_html $(distdir)/tests/tests_2_html
	cp -R $(srcdir)/tests/specifications $(distdir)/tests
#	cp -R $(srcdir)/tests/code/tests.config $(distdir)/tests/code/tests.config
	cp -R $(srcdir)/tests/tests.config $(distdir)/tests/tests.config
	cp -R $(srcdir)/tests.config $(distdir)
#	cp -R $(srcdir)/tests/perl $(distdir)/tests
	( cd $(distdir)/tests && chmod -R u+w . && ./tests_2_html --introduction introduction.html )

#perl_HEADERS = studio_test.pm

#TESTS = studio_test.pm

clean-local:
	$(RM) -f $(top_builddir)/*.dsc
	$(RM) -f $(top_builddir)/*.changes
	$(RM) -f $(top_builddir)/*.deb
	$(RM) -rf $(top_builddir)/RPM_BUILD
	$(RM) -f $(top_builddir)/build_debian.log
	$(RM) -f $(top_builddir)/build_rpm.log
	$(RM) $(top_builddir)/studio-*.tar.gz
	$(RM) -rf $(top_srcdir)/pkg

test: check

html-upload-prepare:
	rm -fr html/htdocs/neurospaces_project/studio/
	mkdir --parents html/htdocs/neurospaces_project/studio
	mkdir --parents html/htdocs/neurospaces_project/studio/html_source
	( cd tests && chmod -R u+w . && ./tests_2_html --introduction introduction.html )
	tar cfh - tests/html | ( cd html/htdocs/neurospaces_project/studio && tar vxf - )
# copy the bin/neurospaces script too
	mkdir --parents html/htdocs/neurospaces_project/studio/tests/bin
#	cp -a tests/bin/* html/htdocs/neurospaces_project/studio/tests/bin

html-upload: html-upload-prepare
	scp -pr html/htdocs/* hcornelis,neurospaces@web.sourceforge.net:/home/groups/n/ne/neurospaces/htdocs/

#perldir = $(prefix)/glue/swig/perl

#nobase_perl_DATA = \
#	studio_test.pm \
#	@PERL_EMBED_DATA@

#perldir = $(prefix)/glue/swig/perl

#nobase_perl_DATA = @PERL_EMBED_DATA@

docs: html-upload-prepare


#-------------------------------------------------------
# Packaging
# the pkg-src target must create pkg/$(APP_NAME)-$(VERSION).tar.gz
TMP_DIR = tmp

pkg-src: dist
	mkdir -p pkg
	cp $(PACKAGE)-$(VERSION).tar.gz pkg/$(PACKAGE)-$(VERSION).tar.gz


pkg-deb: dist
	nspkg-deb $(TMP_DIR) $(PACKAGE) $(VERSION)

pkg-rpm: dist
	nspkg-rpm $(PACKAGE) $(VERSION)

#--- end packaging --------------------------------------