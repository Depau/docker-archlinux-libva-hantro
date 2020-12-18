FROM depau/archlinux-makepkg:aarch64 AS pkgbuilder

RUN echo "MAKEFLAGS='-j$(nproc)'" | sudo tee -a /etc/makepkg.conf && \
    yay -Syu --noprogressbar --noconfirm --mflags=-A

RUN sudo mkdir -p /aur && sudo chown -R builder /aur && cd /aur && \
    git clone --depth 1 https://aur.archlinux.org/libva-hantro-h264-git.git && \
    git clone --depth 1 https://aur.archlinux.org/libva-v4l2-request-hantro-h264-git.git && \
    cd /aur/libva-hantro-h264-git && \
    makepkg -sAc --skippgpcheck --noconfirm --noprogressbar && \
    yes | sudo pacman -U *.pkg.tar* && \
    cd /aur/libva-v4l2-request-hantro-h264-git && \
    makepkg -sAc --skippgpcheck --noconfirm --noprogressbar


FROM depau/archlinux-daily:aarch64
MAINTAINER "Davide Depau <davide@depau.eu>"

COPY --from=pkgbuilder /aur/*/*.pkg.tar* /tmp/
RUN pacman -U --noconfirm /tmp/*.pkg.tar* && rm /tmp/*.pkg.tar*
ENV LIBVA_DRIVER_NAME=v4l2_request
