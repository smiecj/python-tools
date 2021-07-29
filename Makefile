install_pip:
	sh python2/install_pip.sh 

install_jupyter:
	sh jupyter/install_jupyter.sh

install_conda:
	sh python2/install_conda.sh

clean:
	find -name 'logs' | grep -v git | xargs rm -rf
	find -name 'packages' | xargs rm -rf