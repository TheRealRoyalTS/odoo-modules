

FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye



ENV PYTHONUNBUFFERED=1

RUN    apt-get update \
    && apt-get install libldap2-dev libsasl2-dev xfonts-base xfonts-75dpi fontconfig python3-pypdf2 --no-install-recommends -yq \
    && apt-get install postgresql-client --no-install-recommends -yq \
    && apt-get install bash-completion --no-install-recommends -yq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# We are using a fork of pytest-odoo as long as
# https://github.com/camptocamp/pytest-odoo/pull/83 and https://github.com/camptocamp/pytest-odoo/pull/82
# are not merged
# When they are merged, the git source can be replaced with "pytest-odoo<3"
# then the fork can be deleted
RUN pip3 install "pytest<9" "pytest-odoo @ git+https://github.com/42nerds/pytest-odoo.git" pytest-cov pylint_odoo

# Install wkhtmltopdf as it is needed by Odoo to generate reports
RUN    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.5-1.buster_amd64.deb

# Create directories meant to be used by the vscode user
RUN mkdir /vendored/ && chown vscode /vendored
RUN mkdir /data/ && chown vscode /data

USER vscode

# now we clone Odoo CE
RUN mkdir /vendored/odoo
RUN git clone -b "18.0" --depth 1 https://github.com/odoo/odoo.git /vendored/odoo
# Install Odoo CE dependencies
RUN find /vendored/odoo -name requirements.txt | while read -r file; do \
        echo "Installing requirements from $file"; \
        pip install -r "$file"; \
    done

# Install hitchhiker
RUN pip install "hitchhiker[copier,odoo] @ git+https://github.com/42nerds/hitchhiker.git"

# Install other tools
RUN pip install black

USER root

# hitchhiker shell completion
RUN echo 'eval "$(_HITCHHIKER_COMPLETE=bash_source hitchhiker)"' >> /etc/bash.bashrc
