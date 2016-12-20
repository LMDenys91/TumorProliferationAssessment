FROM ermaker/keras

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
ADD .jupyter/jupyter_notebook_config.py /.jupyter/jupyter_notebook_config.py
ADD .jupyter/notebook.key /.jupyter/notebook.key
ADD .jupyter/notebook.pem /.jupyter/notebook.pem
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# Download and unzip Rclone
ADD http://downloads.rclone.org/rclone-v1.32-linux-amd64.zip /usr/bin/rclone.zip
RUN apt-get update && apt-get install && apt-get install -y apt-utils zip unzip sudo wget file vim \
    && unzip /usr/bin/rclone.zip && cd rclone-v1.32-linux-amd64 \
    && sudo cp rclone /usr/sbin/ && sudo chown root:root /usr/sbin/rclone \
    && sudo chmod 755 /usr/sbin/rclone && apt-get install -y ca-certificates

# Install OpenCV
# RUN	apt-get install -y -q build-essential checkinstall git curl cmake pkg-config
# RUN apt-get install -y libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev
# RUN apt-get install -y libgtk2.0-dev
# RUN apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
# RUN apt-get install libatlas-base-dev gfortran
# RUN git clone https://github.com/Itseez/opencv_contrib.git && cd opencv_contrib && git checkout 3.0.0
# RUN git clone https://github.com/Itseez/opencv.git && cd opencv && git checkout 3.0.0 \
#    && mkdir build && cd build && cmake -D CMAKE_BUILD_TYPE=RELEASE \
#	   -D CMAKE_INSTALL_PREFIX=/usr/local \
#	    -D INSTALL_C_EXAMPLES=ON \
#	     -D INSTALL_PYTHON_EXAMPLES=ON \
#	      -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
#	       -D BUILD_EXAMPLES=ON ..
#     && make -j4 && make install && ldconfig
RUN conda install opencv

# Install OpenSlide
RUN apt-get install -y openslide-tools
RUN pip install --upgrade pip && pip install openslide-python

# Install Anaconda, Jupyter, Matplotlib, SKLearn, mpld3, Seaborn, Boto3, AWS CLI, Scandir and Progress bar
RUN sudo apt-get install -y libfreetype6-dev libxft-dev
RUN pip install jupyter \
    matplotlib \
    scikit-learn \
    mpld3 \
    seaborn \
    boto3 \
    awscli \
    scandir \
    progressbar2

# Install ML Metrics
RUN easy_install ml_metrics

# Install Rmate
ADD https://raw.githubusercontent.com/aurora/rmate/master/rmate /usr/bin/rmate
RUN sudo chmod +x /usr/bin/rmate

# VOLUME /deeplearning
# WORKDIR /deeplearning

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--config=/.jupyter/jupyter_notebook_config.py"]
