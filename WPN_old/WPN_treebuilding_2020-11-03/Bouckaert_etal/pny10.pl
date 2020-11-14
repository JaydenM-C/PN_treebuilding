$s='GlossID	Gloss	Subgroup	Language	Word	MultistateCode

<<INSERT COGNATE MATRIX HERE (pny10.tsv)>>

';
@s = split('
',$s);

$n = 0;
for $s (@s) {
	@x = split('\t',$s);
	$d{$x[3],$x[0]} = $d{$x[3],$x[0]}." ".$x[5];
	$word{$x[3],$x[0]} = $x[4];
	$class{$x[3],$x[0]} = $x[2];

	$count[$x[0]][$x[5]] = $count[$x[0]][$x[5]] + 1;
if ($lan{$x[3]} != 1) {
	$lan{$x[3]} = 1;
}
	$w[$x[0]] = $x[1];
$n++;
}

@s = keys(%lan);
print STDERR "$#s languages about $n cognate/words\n";

$nlan=0;
for $lan (sort(keys(%lan))) {
    $nlan++;
}

$THRESHOLD = 1;

sub printNexus {
	$nchar = 0;
	$entries = '';
	for ($i = 1; $i <=204; $i++) {
		for ($j = 1; $j <=704; $j++) {
			if ($count[$i][$j]>$THRESHOLD) {
				$nchar++;
				$entries .= "#$w[$i] $j\n";
			}
		}
	}

	print "#NEXUS\n";
	print "\n#All cognates from pny7-multistate.tab with more than $THRESHOLD occurances\n\n";
	print "Begin data;\n";
	print "Dimensions ntax=$nlan nchar=$nchar;\n";
	print "Format datatype=binary symbols=\"01\" gap=-;\n";
	print "Matrix\n";

	for $lan (sort(keys(%lan))) {
		$s = $lan;
		$s =~ s/ //g;
		$s =~ s/'//g;
		print "$s ";
		for ($i = 1; $i <=204; $i++) {
			for ($j = 1; $j <=704; $j++) {
				if ($count[$i][$j]>$THRESHOLD) {
					$cognate{$i,$j}=1;
					if ($d{$lan,$i} == $j) {
						print '1';
					} elsif ($d{$lan,$i} == 0) {
						print '-';
					} else {
						print '0';
					}
				}
			}		
		}
		print "\n";
	}

	print ";\nEnd;\n";
	print $entries;
}

$k = 0;
print STDERR "\#site word cognate count\n";
for ($i = 1; $i <=204; $i++) {
	for ($j = 1; $j <=204; $j++) {
		if ($cognate{$i,$j} == 1) {
			$k++;
			print "\#"."$k $i $j $count[$i][$j]\n";
		}
	}
}

sub printOccurrances {
	for ($i = 1; $i <=204; $i++) {
		for ($j = 1; $j <=204; $j++) {
			if ($count[$i][$j]>0) {
				$n[$count[$i][$j]] = $n[$count[$i][$j]] + 1;
			}
		}
	}

	$sum = 0;
	for ($i = 0; $i <=80; $i++) {
		$sum += $n[$i];
		print STDERR "$i $n[$i] $sum\n";
	}
}

for ($i = 1; $i <=204; $i++) {
	for ($j = 1; $j <=204; $j++) {
		$count[$i][$j] = 0;
	}
}

for $lan (keys(%lan)) {
	for ($i = 1; $i <=204; $i++) {
		$c = $d{$lan,$i};
		if (($c ne 0) && ($c ne '')) {
			$count[$i][$c] += 1;
		}
	}
}



for ($i = 1; $i <=204; $i++) {
	for $lan (keys(%lan)) {
		print STDERR "$i\t";
		print STDERR "$w[$i]\t";
		print STDERR "$lan\t".$class{$lan,$i}."\t$word{$lan,$i}\t";
		print STDERR "$d{$lan,$i}\n"
	}
}




printNexus();
# printNexus();
# exit;

