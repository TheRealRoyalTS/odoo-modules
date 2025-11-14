# CODESPACE_VSCODE_FOLDER environment variable points to the root folder in a Codespace
CODESPACE_VSCODE_FOLDER := $(or $(CODESPACE_VSCODE_FOLDER), $(PWD))

# Set the target directory for cloning Odoo and Enterprise
VENDOR_DIR := /vendored

ODOO_DB := odoo



.PHONY:




install:
	@echo "Installing requirements..."
	@find $(VENDOR_DIR) -name requirements.txt | while read -r file; do \
		echo "Installing requirements from $$file"; \
		pip3 install -r "$$file"; \
	done
	@echo "Requirements installation completed."
	@echo "Installing dev_requirements..."
	pip3 install -r dev_requirements.txt || true
	@echo "Development requirements installation completed."


.PHONY: setup
setup: install
	@echo "Setting up Odoo..."
	@python3 $(VENDOR_DIR)/odoo/odoo-bin \
		-r odoo -w odoo -d $(ODOO_DB) --db_host db --db_port 5432 \
		--addons-path $(VENDOR_DIR)/odoo/addons,$(shell hitchhiker modules generate_addons_path) \
		-i base \
		--limit-time-cpu=600 --limit-time-real=1200 \
		-D /data/.odoo -c odoo.conf  --unaccent --save --stop-after-init


.PHONY: update_modules
update_modules:
	@echo "Updating modules..."
	@dirs=$$(find $(CODESPACE_VSCODE_FOLDER) -type f -name "__manifest__.py" -not -path '$(VENDOR_DIR)/*' -exec dirname {} \; | xargs -I {} basename {} | tr '\n' ',' | sed 's/,$$//g'); \
	echo "Updating modules in directories: $$dirs"; \
	set -x; \
	python3 $(VENDOR_DIR)/odoo/odoo-bin --c odoo.conf -u $$dirs --no-http --stop-after-init --i18n-overwrite; \
	set +x

# https://stackoverflow.com/a/14061796
ifeq (generate_pot,$(firstword $(MAKECMDGOALS)))
  ifeq (2,$(words $(MAKECMDGOALS)))
    # ...use the second word as the argument
    GENERATE_POT_ARGS := $(word 2,$(MAKECMDGOALS))
  else
    $(error "usage: make generate_pot module1")
  endif
    # ...and turn it into a do-nothing target
    $(eval $(GENERATE_POT_ARGS):;@:)
endif

.PHONY: generate_pot
generate_pot:
	python3 $(VENDOR_DIR)/odoo/odoo-bin -c odoo.conf -i $(GENERATE_POT_ARGS) --no-http --stop-after-init
	@MODULE_DIR=$$(find . -type d -name "$(GENERATE_POT_ARGS)"); \
	mkdir -p "$$MODULE_DIR"/i18n; \
	python3 $(VENDOR_DIR)/odoo/odoo-bin -c odoo.conf --modules $(GENERATE_POT_ARGS) -d $(ODOO_DB) --i18n-export "$$MODULE_DIR"/i18n/$(GENERATE_POT_ARGS).pot


# https://stackoverflow.com/a/14061796
ifeq (install_modules,$(firstword $(MAKECMDGOALS)))
  ifeq (2,$(words $(MAKECMDGOALS)))
    # ...use the second word as the argument
    INSTALL_MODULES_ARGS := $(word 2,$(MAKECMDGOALS))
  else
    $(error "usage: make install_modules module1,module2")
  endif
  # ...and turn it into a do-nothing target
  $(eval $(INSTALL_MODULES_ARGS):;@:)
endif


.PHONY: install_modules
install_modules:
	python3 $(VENDOR_DIR)/odoo/odoo-bin -c odoo.conf -i $(INSTALL_MODULES_ARGS) --no-http --stop-after-init

.PHONY: shell
shell:
	@python3 $(VENDOR_DIR)/odoo/odoo-bin shell -c odoo.conf

ifeq (format,$(firstword $(MAKECMDGOALS)))
  ifeq (2,$(words $(MAKECMDGOALS)))
    # ...use the second word as the argument
    FORMAT_ARGS := $(word 2,$(MAKECMDGOALS))
  else
    $(error "usage: make format directory")
  endif
  # ...and turn it into a do-nothing target
  $(eval $(FORMAT_ARGS):;@:)
endif

.PHONY: format
format:
	black $(FORMAT_ARGS)


.PHONY: unittest_coverage
unittest_coverage:
	coverage run --source=. $(VENDOR_DIR)/odoo/odoo-bin \
		-c odoo.conf \
		--stop-after-init \
		--test-tags="$$(find . -type f -name "__manifest__.py" -not -path '$(VENDOR_DIR)/*' -exec dirname {} \; | xargs -I {} basename {} | sed 's/^/\//' | tr '\n' ',' | sed 's/,$$//g')"
	coverage report -m


.PHONY: drop_database
drop_database:
	PGPASSWORD=odoo psql -h db -U odoo -d postgres -c 'DROP DATABASE "$(ODOO_DB)";'
	rm -rf "/data/.odoo/filestore/$(ODOO_DB)"
