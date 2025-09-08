#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

set -euxo pipefail

# This script is run before building ExecuTorch binaries

if [[ "$(uname -m)" == "aarch64" ]]; then
  file="extension/llm/tokenizers/third-party/sentencepiece/src/CMakeLists.txt"

  # Replace quoted or unquoted atomic with the literal ${ATOMIC_LIB}
  # Note the single quotes around the sed script, so the shell won't expand ${...}.
  sed -E 's/list\([[:space:]]*APPEND[[:space:]]+SPM_LIBS[[:space:]]+("?)(atomic)\1[[:space:]]*\)/list(APPEND SPM_LIBS \${ATOMIC_LIB})/g' \
    "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

  grep -n 'list(APPEND SPM_LIBS ${ATOMIC_LIB})' "$file" && echo "the file $file has been modified for atomic to use full path"

fi



# Manually install build requirements because `python setup.py bdist_wheel` does
# not install them. TODO(dbort): Switch to using `python -m build --wheel`,
# which does install them. Though we'd need to disable build isolation to be
# able to see the installed torch package.

"${GITHUB_WORKSPACE}/${REPOSITORY}/install_requirements.sh"  --example
