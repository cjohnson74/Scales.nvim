.PHONY: install test deploy clean

install:
	@echo "Installing dependencies..."
	pip install -e .

test:
	@echo "Running tests..."
	nvim --headless -c "lua require('tests.install_test').test_installation()" -c "qa"
	nvim --headless -c "lua require('tests.functionality_test').test_functionality()" -c "qa"
	python -m pytest tests/

deploy:
	@echo "Preparing for deployment..."
	@# Check if all required files exist
	@test -f README.md || (echo "README.md not found" && exit 1)
	@test -f LICENSE || (echo "LICENSE not found" && exit 1)
	@test -f setup.py || (echo "setup.py not found" && exit 1)
	@test -d plugin || (echo "plugin directory not found" && exit 1)
	@test -d lua || (echo "lua directory not found" && exit 1)
	@test -d templates || (echo "templates directory not found" && exit 1)
	@echo "All required files present. Ready for deployment."

clean:
	@echo "Cleaning up..."
	rm -rf __pycache__/
	rm -rf .pytest_cache/
	rm -rf *.egg-info/
	rm -rf build/
	rm -rf dist/
	rm -f *.pyc
	rm -f *.pyo
	rm -f .coverage