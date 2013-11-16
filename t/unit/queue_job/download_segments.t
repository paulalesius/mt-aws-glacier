#!/usr/bin/env perl

# mt-aws-glacier - Amazon Glacier sync client
# Copyright (C) 2012-2013  Victor Efimov
# http://mt-aws.com (also http://vs-dev.com) vs@vs-dev.com
# License: GPLv3
#
# This file is part of "mt-aws-glacier"
#
#    mt-aws-glacier is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    mt-aws-glacier is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Test::More tests => 3334;
use Test::Deep;
use Data::Dumper;
use Carp;
use FindBin;
use lib map { "$FindBin::RealBin/../$_" } qw{../lib ../../lib};
use App::MtAws::QueueJobResult;
use App::MtAws::QueueJob::DownloadSegments;
use QueueHelpers;
use LCGRandom;
use TestUtils;
use DownloadSegmentsTest qw/test_case_full test_case_lite test_case_random_finish ONE_MB/;

warning_fatal();


lcg_srand 467287 => sub {
	# manual testing segment sizes
	
	test_case_full ONE_MB, 1, [ONE_MB];
	test_case_full ONE_MB+1, 1, [ONE_MB, 1];
	test_case_full ONE_MB-1, 1, [ONE_MB-1];
	
	
	test_case_full 2*ONE_MB, 2, [2*ONE_MB];
	test_case_full 2*ONE_MB+1, 2, [2*ONE_MB, 1];
	test_case_full 2*ONE_MB+2, 2, [2*ONE_MB, 2];
	test_case_full 2*ONE_MB-1, 2, [2*ONE_MB-1];
	test_case_full 2*ONE_MB-2, 2, [2*ONE_MB-2];
	
	
	test_case_full 4*ONE_MB, 2, [2*ONE_MB, 2*ONE_MB];
	test_case_full 4*ONE_MB+1, 2, [2*ONE_MB, 2*ONE_MB, 1];
	test_case_full 4*ONE_MB-1, 2, [2*ONE_MB, 2*ONE_MB-1];

	# auto testing segment sizes

	for my $segment (1, 2, 8, 16) {
		for my $size (2, 3, 15) {
			if ($size*ONE_MB >= 2*$segment*ONE_MB) { # avoid some unneeded testing
				for my $delta (-30, -2, -1, 0, 1, 2, 27) {
					test_case_lite $size*ONE_MB+$delta, $segment;
					test_case_random_finish($size*ONE_MB+$delta, $segment, $_) for (1..4);
				}
			}
		}
	}
};

1;

__END__
