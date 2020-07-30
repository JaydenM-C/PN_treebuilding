#!/bin/bash

model=("CMGR" "CMGS" "CMHR" "CMHS" "CSGR" "CSGS" "CSHR" "CSHS" "SMGR" "SMGS" "SMHR" "SMHS" "SSGR" "SSGS" "SSHR" "SSHS")

for m in ${model[@]}
do
	dir=biphone_binary_${m}
	mkdir $dir/MLE
	chain_1=$dir/output/biphone_binary_${m}_2020-07-23_ch1.mle.log
	chain_2=$dir/output/biphone_binary_${m}_2020-07-23_ch2.mle.log
	res=$dir/MLE/biphone_binary_${m}_2020-07-23.mle.result.log

	beast_xml=$( <<- EOF
	<?xml version="1.0" standalone="yes"?>

	<beast version="1.10.4">

		<pathSamplingAnalysis fileName="$chain_1 $chain2" resultsFileName="$res">
			<likelihoodColumn name="pathLikelihood.delta"/>
			<thetaColumn name="pathLikelihood.theta"/>
		</pathSamplingAnalysis>

		<!-- Stepping-stone sampling estimator from collected samples                -->
		<steppingStoneSamplingAnalysis fileName="$chain_1 $chain_2" resultsFileName="$res">
			<likelihoodColumn name="pathLikelihood.delta"/>
			<thetaColumn name="pathLikelihood.theta"/>
		</steppingStoneSamplingAnalysis>

	</beast>
	EOF
	)

	../BEASTv1.10.4/bin/beast $beast_xml

done
